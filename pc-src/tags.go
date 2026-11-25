package main

import (
	"bytes"
	"encoding/binary"
	"io"
	"os"
	"path/filepath"
	"strings"
	"unicode/utf16"
)

type meta struct {
	T  string `json:"t,omitempty"`
	A  string `json:"a,omitempty"`
	Al string `json:"al,omitempty"`
	D  int64  `json:"d,omitempty"` // ms
}

type id3Tag struct {
	frames map[string][]byte
	size   int64 // 태그 전체 길이(헤더 포함)
	ver    byte
}

func syncsafe(b []byte) int64 {
	return int64(b[0]&0x7f)<<21 | int64(b[1]&0x7f)<<14 | int64(b[2]&0x7f)<<7 | int64(b[3]&0x7f)
}

func readID3(f *os.File) *id3Tag {
	h := make([]byte, 10)
	if _, err := f.ReadAt(h, 0); err != nil || string(h[:3]) != "ID3" {
		return nil
	}
	ver, flags := h[3], h[5]
	size := syncsafe(h[6:10])
	if size <= 0 || size > 32<<20 {
		return nil
	}
	body := make([]byte, size)
	if n, _ := f.ReadAt(body, 10); int64(n) < size {
		body = body[:n]
	}
	if flags&0x80 != 0 && ver < 4 { // unsynchronisation (v2.3 전체)
		body = bytes.ReplaceAll(body, []byte{0xff, 0x00}, []byte{0xff})
	}
	t := &id3Tag{frames: map[string][]byte{}, size: 10 + size, ver: ver}
	if flags&0x10 != 0 {
		t.size += 10
	}
	pos := 0
	if flags&0x40 != 0 && len(body) > 4 { // extended header
		if ver == 4 {
			pos = int(syncsafe(body[0:4]))
		} else {
			pos = int(binary.BigEndian.Uint32(body[0:4])) + 4
		}
	}
	for {
		if ver == 2 {
			if pos+6 > len(body) || body[pos] == 0 {
				break
			}
			id := string(body[pos : pos+3])
			sz := int(body[pos+3])<<16 | int(body[pos+4])<<8 | int(body[pos+5])
			pos += 6
			if sz <= 0 || pos+sz > len(body) {
				break
			}
			if _, ok := t.frames[id]; !ok {
				t.frames[id] = body[pos : pos+sz]
			}
			pos += sz
			continue
		}
		if pos+10 > len(body) || body[pos] == 0 {
			break
		}
		id := string(body[pos : pos+4])
		var sz int
		if ver == 4 {
			sz = int(syncsafe(body[pos+4 : pos+8]))
		} else {
			sz = int(binary.BigEndian.Uint32(body[pos+4 : pos+8]))
		}
		fl := body[pos+9]
		pos += 10
		if sz <= 0 || pos+sz > len(body) {
			break
		}
		fr := body[pos : pos+sz]
		if ver == 4 && fl&0x02 != 0 {
			fr = bytes.ReplaceAll(fr, []byte{0xff, 0x00}, []byte{0xff})
		}
		if ver == 4 && fl&0x01 != 0 && len(fr) >= 4 { // data length indicator
			fr = fr[4:]
		}
		if _, ok := t.frames[id]; !ok {
			t.frames[id] = fr
		}
		pos += sz
	}
	return t
}

func decText(enc byte, b []byte) string {
	switch enc {
	case 1, 2: // UTF-16 (BOM) / UTF-16BE
		be := enc == 2
		if len(b) >= 2 && b[0] == 0xff && b[1] == 0xfe {
			be, b = false, b[2:]
		} else if len(b) >= 2 && b[0] == 0xfe && b[1] == 0xff {
			be, b = true, b[2:]
		}
		u := make([]uint16, 0, len(b)/2)
		for i := 0; i+1 < len(b); i += 2 {
			var c uint16
			if be {
				c = uint16(b[i])<<8 | uint16(b[i+1])
			} else {
				c = uint16(b[i+1])<<8 | uint16(b[i])
			}
			if c == 0 {
				break
			}
			u = append(u, c)
		}
		return strings.TrimSpace(string(utf16.Decode(u)))
	case 3:
		if i := bytes.IndexByte(b, 0); i >= 0 {
			b = b[:i]
		}
		return strings.TrimSpace(string(b))
	default:
		if i := bytes.IndexByte(b, 0); i >= 0 {
			b = b[:i]
		}
		r := make([]rune, len(b))
		for i, c := range b {
			r[i] = rune(c)
		}
		return strings.TrimSpace(string(r))
	}
}

func (t *id3Tag) text(ids ...string) string {
	for _, id := range ids {
		if fr, ok := t.frames[id]; ok && len(fr) > 1 {
			if s := decText(fr[0], fr[1:]); s != "" {
				return s
			}
		}
	}
	return ""
}

func readMeta(p string) meta {
	var m meta
	f, err := os.Open(p)
	if err != nil {
		return m
	}
	defer f.Close()
	st, _ := f.Stat()
	ext := strings.ToLower(filepath.Ext(p))
	var audioStart int64
	if t := readID3(f); t != nil {
		m.T = t.text("TIT2", "TT2")
		m.A = t.text("TPE1", "TP1", "TPE2", "TP2")
		m.Al = t.text("TALB", "TAL")
		audioStart = t.size
	}
	if ext == ".mp3" && m.T == "" && st != nil && st.Size() > 128 {
		v1 := make([]byte, 128)
		if _, err := f.ReadAt(v1, st.Size()-128); err == nil && string(v1[:3]) == "TAG" {
			m.T, m.A, m.Al = decText(0, v1[3:33]), decText(0, v1[33:63]), decText(0, v1[63:93])
		}
	}
	if ext == ".flac" {
		flacMeta(f, &m)
	}
	if st != nil {
		switch ext {
		case ".mp3":
			m.D = mp3Duration(f, audioStart, st.Size())
		case ".wav":
			m.D = wavDuration(f)
		}
	}
	return m
}

var brTab = [2][16]int{
	{0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0}, // MPEG1 L3
	{0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0},     // MPEG2/2.5 L3
}
var srTab = [3][3]int{{44100, 48000, 32000}, {22050, 24000, 16000}, {11025, 12000, 8000}}

func mp3Duration(f *os.File, start, size int64) int64 {
	buf := make([]byte, 64*1024)
	n, _ := f.ReadAt(buf, start)
	buf = buf[:n]
	for i := 0; i+4 <= len(buf); i++ {
		if buf[i] != 0xff || buf[i+1]&0xe0 != 0xe0 {
			continue
		}
		verBits, layer := (buf[i+1]>>3)&3, (buf[i+1]>>1)&3
		bri, sri := buf[i+2]>>4, (buf[i+2]>>2)&3
		if verBits == 1 || layer != 1 || bri == 0 || bri == 15 || sri == 3 {
			continue
		}
		v := map[byte]int{3: 0, 2: 1, 0: 2}[verBits]
		sr := srTab[v][sri]
		br := brTab[min(v, 1)][bri] * 1000
		spf := 1152
		if v > 0 {
			spf = 576
		}
		mono := buf[i+3]>>6 == 3
		// Xing/Info/VBRI 헤더가 있으면 프레임 수로 정확히
		var off int
		switch {
		case v == 0 && !mono:
			off = 36
		case v == 0 && mono:
			off = 21
		case v > 0 && !mono:
			off = 21
		default:
			off = 13
		}
		if i+off+12 <= len(buf) {
			tag := string(buf[i+off : i+off+4])
			if (tag == "Xing" || tag == "Info") && buf[i+off+7]&1 != 0 {
				frames := int64(binary.BigEndian.Uint32(buf[i+off+8 : i+off+12]))
				return frames * int64(spf) * 1000 / int64(sr)
			}
		}
		if i+36+18 <= len(buf) && string(buf[i+36:i+40]) == "VBRI" {
			frames := int64(binary.BigEndian.Uint32(buf[i+36+14 : i+36+18]))
			return frames * int64(spf) * 1000 / int64(sr)
		}
		audio := size - start - int64(i)
		return audio * 8 * 1000 / int64(br)
	}
	return 0
}

func wavDuration(f *os.File) int64 {
	h := make([]byte, 4096)
	n, _ := f.ReadAt(h, 0)
	h = h[:n]
	if n < 12 || string(h[:4]) != "RIFF" || string(h[8:12]) != "WAVE" {
		return 0
	}
	var byteRate int64
	for pos := 12; pos+8 <= len(h); {
		id, sz := string(h[pos:pos+4]), int64(binary.LittleEndian.Uint32(h[pos+4:pos+8]))
		if id == "fmt " && pos+16 <= len(h) {
			byteRate = int64(binary.LittleEndian.Uint32(h[pos+16 : pos+20]))
		}
		if id == "data" {
			if byteRate > 0 {
				return sz * 1000 / byteRate
			}
			return 0
		}
		pos += 8 + int(sz) + int(sz&1)
	}
	return 0
}

func flacMeta(f *os.File, m *meta) {
	h := make([]byte, 4)
	if _, err := f.ReadAt(h, 0); err != nil || string(h) != "fLaC" {
		return
	}
	pos := int64(4)
	for i := 0; i < 64; i++ {
		bh := make([]byte, 4)
		if _, err := f.ReadAt(bh, pos); err != nil {
			return
		}
		last, typ, ln := bh[0]&0x80 != 0, bh[0]&0x7f, int64(bh[1])<<16|int64(bh[2])<<8|int64(bh[3])
		if typ == 0 && ln >= 18 {
			si := make([]byte, 18)
			f.ReadAt(si, pos+4)
			sr := int64(si[10])<<12 | int64(si[11])<<4 | int64(si[12])>>4
			tot := int64(si[13]&0x0f)<<32 | int64(binary.BigEndian.Uint32(si[14:18]))
			if sr > 0 {
				m.D = tot * 1000 / sr
			}
		}
		if typ == 4 && ln < 1<<20 {
			b := make([]byte, ln)
			f.ReadAt(b, pos+4)
			vorbis(b, m)
		}
		if last {
			return
		}
		pos += 4 + ln
	}
}

func vorbis(b []byte, m *meta) {
	r := bytes.NewReader(b)
	var n uint32
	if binary.Read(r, binary.LittleEndian, &n) != nil || int64(n) > int64(len(b)) {
		return
	}
	r.Seek(int64(n), io.SeekCurrent)
	var cnt uint32
	if binary.Read(r, binary.LittleEndian, &cnt) != nil {
		return
	}
	for i := uint32(0); i < cnt && i < 1000; i++ {
		var l uint32
		if binary.Read(r, binary.LittleEndian, &l) != nil || int64(l) > int64(r.Len()) {
			return
		}
		s := make([]byte, l)
		r.Read(s)
		kv := strings.SplitN(string(s), "=", 2)
		if len(kv) != 2 {
			continue
		}
		switch strings.ToUpper(kv[0]) {
		case "TITLE":
			if m.T == "" {
				m.T = kv[1]
			}
		case "ARTIST":
			if m.A == "" {
				m.A = kv[1]
			}
		case "ALBUM":
			if m.Al == "" {
				m.Al = kv[1]
			}
		}
	}
}

// 곡 안에 들어 있는 앨범 커버
func readArt(p string) ([]byte, string) {
	f, err := os.Open(p)
	if err != nil {
		return nil, ""
	}
	defer f.Close()
	t := readID3(f)
	if t == nil {
		return nil, ""
	}
	if fr, ok := t.frames["APIC"]; ok && len(fr) > 4 {
		enc := fr[0]
		i := bytes.IndexByte(fr[1:], 0)
		if i < 0 {
			return nil, ""
		}
		mimeT := string(fr[1 : 1+i])
		rest := fr[2+i:]
		if len(rest) < 2 {
			return nil, ""
		}
		rest = rest[1:] // picture type
		rest = skipDesc(enc, rest)
		return rest, imgType(mimeT, rest)
	}
	if fr, ok := t.frames["PIC"]; ok && len(fr) > 6 {
		enc := fr[0]
		rest := skipDesc(enc, fr[5:])
		return rest, imgType("", rest)
	}
	return nil, ""
}

func skipDesc(enc byte, b []byte) []byte {
	if enc == 1 || enc == 2 {
		for i := 0; i+1 < len(b); i += 2 {
			if b[i] == 0 && b[i+1] == 0 {
				return b[i+2:]
			}
		}
		return nil
	}
	if i := bytes.IndexByte(b, 0); i >= 0 {
		return b[i+1:]
	}
	return nil
}

func imgType(m string, b []byte) string {
	if len(b) > 4 && b[0] == 0x89 && b[1] == 'P' {
		return "image/png"
	}
	if len(b) > 3 && b[0] == 0xff && b[1] == 0xd8 {
		return "image/jpeg"
	}
	if strings.HasPrefix(m, "image/") {
		return m
	}
	return "image/jpeg"
}
