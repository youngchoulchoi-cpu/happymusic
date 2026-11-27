.class public Lcom/turntable/player/TtsHelper;
.super Ljava/lang/Object;
.implements Landroid/speech/tts/TextToSpeech$OnInitListener;
.implements Ljava/lang/Runnable;

# 영어 발음 듣기 (휴대폰 기본 음성 엔진)
.field public static tts:Landroid/speech/tts/TextToSpeech;
.field public static ready:Z
.field public static pending:Ljava/lang/String;
.field public c:Landroid/content/Context;
.field public x:Ljava/lang/String;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static speak(Landroid/content/Context;Ljava/lang/String;)V
    .locals 3
    :try_start
    sget-object v0, Lcom/turntable/player/TtsHelper;->tts:Landroid/speech/tts/TextToSpeech;
    if-nez v0, :have
    sput-object p1, Lcom/turntable/player/TtsHelper;->pending:Ljava/lang/String;
    new-instance v0, Landroid/speech/tts/TextToSpeech;
    new-instance v1, Lcom/turntable/player/TtsHelper;
    invoke-direct {v1}, Lcom/turntable/player/TtsHelper;-><init>()V
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;
    move-result-object v2
    invoke-direct {v0, v2, v1}, Landroid/speech/tts/TextToSpeech;-><init>(Landroid/content/Context;Landroid/speech/tts/TextToSpeech$OnInitListener;)V
    sput-object v0, Lcom/turntable/player/TtsHelper;->tts:Landroid/speech/tts/TextToSpeech;
    return-void
    :have
    sget-boolean v1, Lcom/turntable/player/TtsHelper;->ready:Z
    if-nez v1, :go
    sput-object p1, Lcom/turntable/player/TtsHelper;->pending:Ljava/lang/String;
    return-void
    :go
    invoke-static {p1}, Lcom/turntable/player/TtsHelper;->say(Ljava/lang/String;)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    :e
    return-void
.end method

.method public static say(Ljava/lang/String;)V
    .locals 4
    :try_start
    sget-object v0, Lcom/turntable/player/TtsHelper;->tts:Landroid/speech/tts/TextToSpeech;
    if-eqz v0, :e
    const/4 v1, 0x0
    const/4 v2, 0x0
    const-string v3, "hm"
    invoke-virtual {v0, p0, v1, v2, v3}, Landroid/speech/tts/TextToSpeech;->speak(Ljava/lang/CharSequence;ILandroid/os/Bundle;Ljava/lang/String;)I
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    :e
    return-void
.end method

.method public onInit(I)V
    .locals 2
    :try_start
    if-nez p1, :fail
    sget-object v0, Lcom/turntable/player/TtsHelper;->tts:Landroid/speech/tts/TextToSpeech;
    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;
    invoke-virtual {v0, v1}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I
    const v1, 0x3f59999a
    invoke-virtual {v0, v1}, Landroid/speech/tts/TextToSpeech;->setSpeechRate(F)I
    const/4 v1, 0x1
    sput-boolean v1, Lcom/turntable/player/TtsHelper;->ready:Z
    sget-object v1, Lcom/turntable/player/TtsHelper;->pending:Ljava/lang/String;
    if-eqz v1, :fail
    invoke-static {v1}, Lcom/turntable/player/TtsHelper;->say(Ljava/lang/String;)V
    const/4 v1, 0x0
    sput-object v1, Lcom/turntable/player/TtsHelper;->pending:Ljava/lang/String;
    :fail
    nop
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    :e
    return-void
.end method

.method public run()V
    .locals 2
    iget-object v0, p0, Lcom/turntable/player/TtsHelper;->c:Landroid/content/Context;
    iget-object v1, p0, Lcom/turntable/player/TtsHelper;->x:Ljava/lang/String;
    invoke-static {v0, v1}, Lcom/turntable/player/TtsHelper;->speak(Landroid/content/Context;Ljava/lang/String;)V
    return-void
.end method
