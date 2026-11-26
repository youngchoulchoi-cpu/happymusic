-- =====================================================================
--  해피뮤직 · 해피톡 서버 설정 (Supabase › SQL Editor 에 통째로 붙여 넣고 Run)
--  여러 번 실행해도 안전합니다. 기존 대화·회원은 지워지지 않아요.
--  첫 번째로 가입한 사람이 자동으로 '관리자'가 됩니다.
-- =====================================================================

create extension if not exists pgcrypto with schema extensions;

-- ---------- 표 ----------
create table if not exists public.hm_profiles(
  id uuid primary key references auth.users(id) on delete cascade,
  nick text not null check (char_length(nick) between 1 and 20),
  role text not null default 'member' check (role in ('admin','member')),
  status text not null default 'active' check (status in ('active','blocked')),
  invited_by uuid,
  created_at timestamptz not null default now(),
  last_seen timestamptz not null default now()
);

create table if not exists public.hm_settings(
  id int primary key default 1 check (id = 1),
  members_can_invite boolean not null default false,
  max_file_mb int not null default 20 check (max_file_mb between 1 and 50)
);
insert into public.hm_settings(id) values (1) on conflict do nothing;

create table if not exists public.hm_invites(
  code text primary key,
  created_by uuid references public.hm_profiles(id) on delete set null,
  note text check (char_length(note) <= 40),
  max_uses int not null default 1 check (max_uses between 1 and 100),
  uses int not null default 0,
  expires_at timestamptz,
  revoked boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.hm_rooms(
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('all','dm')),
  name text,
  dm_key text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.hm_room_members(
  room_id uuid not null references public.hm_rooms(id) on delete cascade,
  user_id uuid not null references public.hm_profiles(id) on delete cascade,
  primary key (room_id, user_id)
);

create table if not exists public.hm_messages(
  id bigint generated always as identity primary key,
  room_id uuid not null references public.hm_rooms(id) on delete cascade,
  sender uuid references public.hm_profiles(id) on delete set null,
  body text check (char_length(body) <= 4000),
  file_path text,
  file_name text check (char_length(file_name) <= 200),
  file_size bigint,
  file_type text,
  deleted boolean not null default false,
  created_at timestamptz not null default now(),
  check (body is not null or file_path is not null or deleted)
);
create index if not exists hm_messages_room_id on public.hm_messages(room_id, id);

-- ---------- 권한 확인 도우미 ----------
create or replace function public.hm_is_active() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from hm_profiles where id = auth.uid() and status = 'active')
$$;
create or replace function public.hm_is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from hm_profiles where id = auth.uid() and status = 'active' and role = 'admin')
$$;
create or replace function public.hm_in_room(r uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select hm_is_active() and exists(select 1 from hm_room_members where room_id = r and user_id = auth.uid())
$$;

-- ---------- 행 단위 보안 (RLS) ----------
alter table public.hm_profiles enable row level security;
alter table public.hm_settings enable row level security;
alter table public.hm_invites enable row level security;
alter table public.hm_rooms enable row level security;
alter table public.hm_room_members enable row level security;
alter table public.hm_messages enable row level security;

drop policy if exists hm_profiles_read on public.hm_profiles;
create policy hm_profiles_read on public.hm_profiles for select to authenticated using (public.hm_is_active());
drop policy if exists hm_settings_read on public.hm_settings;
create policy hm_settings_read on public.hm_settings for select to authenticated using (public.hm_is_active());
drop policy if exists hm_invites_read on public.hm_invites;
create policy hm_invites_read on public.hm_invites for select to authenticated using (public.hm_is_admin() or (created_by = auth.uid() and public.hm_is_active()));
drop policy if exists hm_rooms_read on public.hm_rooms;
create policy hm_rooms_read on public.hm_rooms for select to authenticated using (public.hm_in_room(id));
drop policy if exists hm_room_members_read on public.hm_room_members;
create policy hm_room_members_read on public.hm_room_members for select to authenticated using (public.hm_in_room(room_id));
drop policy if exists hm_messages_read on public.hm_messages;
create policy hm_messages_read on public.hm_messages for select to authenticated using (public.hm_in_room(room_id));
drop policy if exists hm_messages_send on public.hm_messages;
create policy hm_messages_send on public.hm_messages for insert to authenticated
  with check (sender = auth.uid() and public.hm_in_room(room_id) and deleted = false
              and (file_path is null or split_part(file_path, '/', 1) = room_id::text));
-- 수정·삭제는 아래 함수로만 (직접 수정 불가)

-- ---------- 기능 (함수) ----------
-- 로그인 전: 관리자가 있는지 (첫 가입자 안내용)
create or replace function public.hm_status() returns json
language sql stable security definer set search_path = public as $$
  select json_build_object('has_admin', exists(select 1 from hm_profiles where role = 'admin'), 'v', 1)
$$;

-- 가입 마무리: 첫 가입자는 관리자, 그다음부터는 초대 코드가 필요
create or replace function public.hm_join(p_nick text, p_code text default null) returns json
language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); inv hm_invites; r uuid; me hm_profiles; is_first boolean;
begin
  if uid is null then raise exception 'not_signed_in'; end if;
  select * into me from hm_profiles where id = uid;
  if found then return row_to_json(me); end if;
  p_nick := nullif(trim(coalesce(p_nick, '')), '');
  if p_nick is null or char_length(p_nick) > 20 then raise exception 'bad_nick'; end if;
  perform pg_advisory_xact_lock(424242);
  is_first := not exists(select 1 from hm_profiles where role = 'admin');
  if not is_first then
    select * into inv from hm_invites
      where code = upper(trim(coalesce(p_code, ''))) and not revoked
        and (expires_at is null or expires_at > now()) and uses < max_uses
      for update;
    if not found then raise exception 'invalid_invite'; end if;
    update hm_invites set uses = uses + 1 where code = inv.code;
  end if;
  insert into hm_profiles(id, nick, role, invited_by)
    values (uid, p_nick, case when is_first then 'admin' else 'member' end, inv.created_by)
    returning * into me;
  select id into r from hm_rooms where kind = 'all' order by created_at limit 1;
  if r is null then insert into hm_rooms(kind, name) values ('all', '전체 채팅') returning id into r; end if;
  insert into hm_room_members(room_id, user_id) values (r, uid) on conflict do nothing;
  return row_to_json(me);
end $$;

create or replace function public.hm_me() returns json
language sql stable security definer set search_path = public as $$
  select row_to_json(p) from hm_profiles p where id = auth.uid()
$$;

create or replace function public.hm_touch() returns void
language sql security definer set search_path = public as $$
  update hm_profiles set last_seen = now() where id = auth.uid()
$$;

create or replace function public.hm_set_nick(p_nick text) returns void
language plpgsql security definer set search_path = public as $$
begin
  p_nick := nullif(trim(coalesce(p_nick, '')), '');
  if p_nick is null or char_length(p_nick) > 20 then raise exception 'bad_nick'; end if;
  update hm_profiles set nick = p_nick where id = auth.uid();
end $$;

-- 1:1 대화방 열기 (없으면 만든다)
create or replace function public.hm_dm(p_other uuid) returns uuid
language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); k text; r uuid;
begin
  if not hm_is_active() then raise exception 'not_allowed'; end if;
  if p_other = uid or not exists(select 1 from hm_profiles where id = p_other and status = 'active') then raise exception 'bad_user'; end if;
  k := least(uid::text, p_other::text) || ':' || greatest(uid::text, p_other::text);
  select id into r from hm_rooms where dm_key = k;
  if r is null then
    insert into hm_rooms(kind, dm_key) values ('dm', k) on conflict (dm_key) do nothing returning id into r;
    if r is null then select id into r from hm_rooms where dm_key = k; end if;
  end if;
  insert into hm_room_members(room_id, user_id) values (r, uid), (r, p_other) on conflict do nothing;
  return r;
end $$;

-- 내 대화방 목록 + 마지막 메시지
create or replace function public.hm_rooms() returns table(id uuid, kind text, name text, peer uuid, peer_nick text, last_id bigint, last_body text, last_file text, last_sender uuid, last_at timestamptz)
language sql stable security definer set search_path = public as $$
  select r.id, r.kind, r.name, p.id, p.nick, m.id, case when m.deleted then null else m.body end, m.file_name, m.sender, coalesce(m.created_at, r.created_at)
  from hm_rooms r
  join hm_room_members me on me.room_id = r.id and me.user_id = auth.uid()
  left join lateral (select pm.user_id from hm_room_members pm where pm.room_id = r.id and pm.user_id <> auth.uid() and r.kind = 'dm' limit 1) o on true
  left join hm_profiles p on p.id = o.user_id
  left join lateral (select * from hm_messages mm where mm.room_id = r.id order by mm.id desc limit 1) m on true
  where hm_is_active()
  order by (r.kind = 'all') desc, coalesce(m.created_at, r.created_at) desc
$$;

-- 메시지 지우기 (보낸 사람 또는 관리자)
create or replace function public.hm_delete_message(p_id bigint) returns text
language plpgsql security definer set search_path = public as $$
declare m hm_messages;
begin
  select * into m from hm_messages where id = p_id;
  if not found then raise exception 'not_found'; end if;
  if not (hm_is_admin() or (m.sender = auth.uid() and hm_is_active())) then raise exception 'not_allowed'; end if;
  update hm_messages set deleted = true, body = null where id = p_id;
  return m.file_path;
end $$;

-- 초대 코드 만들기 (관리자, 또는 '멤버도 초대 가능'일 때 멤버)
create or replace function public.hm_create_invite(p_max int default 1, p_days int default 7, p_note text default null) returns text
language plpgsql security definer set search_path = public as $$
declare c text; ok boolean;
begin
  ok := hm_is_admin() or (hm_is_active() and (select members_can_invite from hm_settings where id = 1));
  if not ok then raise exception 'not_allowed'; end if;
  p_max := greatest(1, least(coalesce(p_max, 1), 100));
  loop
    c := upper(substr(translate(encode(extensions.gen_random_bytes(9), 'base64'), '+/=01OIl', ''), 1, 8));
    exit when char_length(c) = 8 and not exists(select 1 from hm_invites where code = c);
  end loop;
  insert into hm_invites(code, created_by, note, max_uses, expires_at)
    values (c, auth.uid(), nullif(trim(coalesce(p_note, '')), ''), p_max,
            case when coalesce(p_days, 0) > 0 then now() + make_interval(days => least(p_days, 365)) end);
  return c;
end $$;

create or replace function public.hm_revoke_invite(p_code text) returns void
language plpgsql security definer set search_path = public as $$
begin
  update hm_invites set revoked = true
   where code = p_code and (hm_is_admin() or (created_by = auth.uid() and hm_is_active()));
end $$;

-- 관리자: 회원 역할 · 상태 바꾸기
create or replace function public.hm_admin_member(p_user uuid, p_role text default null, p_status text default null) returns void
language plpgsql security definer set search_path = public as $$
declare t hm_profiles;
begin
  if not hm_is_admin() then raise exception 'not_allowed'; end if;
  select * into t from hm_profiles where id = p_user for update;
  if not found then raise exception 'not_found'; end if;
  if p_user = auth.uid() and (p_status = 'blocked' or p_role = 'member') then raise exception 'not_self'; end if;
  update hm_profiles set role = coalesce(p_role, role), status = coalesce(p_status, status) where id = p_user;
  if not exists(select 1 from hm_profiles where role = 'admin' and status = 'active') then raise exception 'last_admin'; end if;
end $$;

-- 관리자: 설정
create or replace function public.hm_admin_settings(p_members_can_invite boolean default null, p_max_file_mb int default null) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not hm_is_admin() then raise exception 'not_allowed'; end if;
  update hm_settings set members_can_invite = coalesce(p_members_can_invite, members_can_invite),
                         max_file_mb = coalesce(p_max_file_mb, max_file_mb) where id = 1;
end $$;

-- 관리자: 사용한 파일 용량
create or replace function public.hm_storage_used() returns json
language plpgsql stable security definer set search_path = public as $$
begin
  if not hm_is_admin() then raise exception 'not_allowed'; end if;
  return (select json_build_object('bytes', coalesce(sum(file_size), 0), 'files', count(*))
            from hm_messages where file_path is not null and not deleted);
end $$;

-- 함수 실행 권한
revoke execute on function public.hm_is_active(), public.hm_is_admin(), public.hm_in_room(uuid),
  public.hm_join(text, text), public.hm_me(), public.hm_touch(), public.hm_set_nick(text), public.hm_dm(uuid),
  public.hm_rooms(), public.hm_delete_message(bigint), public.hm_create_invite(int, int, text),
  public.hm_revoke_invite(text), public.hm_admin_member(uuid, text, text), public.hm_admin_settings(boolean, int),
  public.hm_storage_used() from public, anon;
grant execute on function public.hm_status() to anon, authenticated;
grant execute on function public.hm_is_active(), public.hm_is_admin(), public.hm_in_room(uuid),
  public.hm_join(text, text), public.hm_me(), public.hm_touch(), public.hm_set_nick(text), public.hm_dm(uuid),
  public.hm_rooms(), public.hm_delete_message(bigint), public.hm_create_invite(int, int, text),
  public.hm_revoke_invite(text), public.hm_admin_member(uuid, text, text), public.hm_admin_settings(boolean, int),
  public.hm_storage_used() to authenticated;

-- ---------- 파일 보관함 (비공개) ----------
insert into storage.buckets(id, name, public, file_size_limit)
  values ('hm-files', 'hm-files', false, 52428800)
  on conflict (id) do update set public = false;

drop policy if exists hm_files_read on storage.objects;
create policy hm_files_read on storage.objects for select to authenticated
  using (bucket_id = 'hm-files' and public.hm_in_room(((storage.foldername(name))[1])::uuid));
drop policy if exists hm_files_upload on storage.objects;
create policy hm_files_upload on storage.objects for insert to authenticated
  with check (bucket_id = 'hm-files' and public.hm_in_room(((storage.foldername(name))[1])::uuid));
drop policy if exists hm_files_delete on storage.objects;
create policy hm_files_delete on storage.objects for delete to authenticated
  using (bucket_id = 'hm-files' and (owner_id = auth.uid()::text or public.hm_is_admin()));
