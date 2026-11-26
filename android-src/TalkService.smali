.class public Lcom/turntable/player/TalkService;
.super Landroid/app/Service;
.implements Ljava/lang/Runnable;

# 해피톡 알림 대기 (앱 화면이 꺼져 있을 때만 새 메시지를 확인 · 배터리 절약형)
.field public static inst:Lcom/turntable/player/TalkService;
.field public h:Landroid/os/Handler;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Service;-><init>()V
    return-void
.end method

.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .locals 1
    const/4 v0, 0x0
    return-object v0
.end method

.method public onCreate()V
    .locals 2
    invoke-super {p0}, Landroid/app/Service;->onCreate()V
    sput-object p0, Lcom/turntable/player/TalkService;->inst:Lcom/turntable/player/TalkService;
    new-instance v0, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v1
    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    iput-object v0, p0, Lcom/turntable/player/TalkService;->h:Landroid/os/Handler;
    return-void
.end method

.method public onStartCommand(Landroid/content/Intent;II)I
    .locals 2
    invoke-direct {p0}, Lcom/turntable/player/TalkService;->fg()V
    const-wide/16 v0, 0xbb8
    invoke-virtual {p0, v0, v1}, Lcom/turntable/player/TalkService;->schedule(J)V
    const/4 v0, 0x1
    return v0
.end method

.method public schedule(J)V
    .locals 1
    iget-object v0, p0, Lcom/turntable/player/TalkService;->h:Landroid/os/Handler;
    if-eqz v0, :r
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    invoke-virtual {v0, p0, p1, p2}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    :r
    return-void
.end method

.method public run()V
    .locals 1
    new-instance v0, Lcom/turntable/player/TalkPoll;
    invoke-direct {v0, p0}, Lcom/turntable/player/TalkPoll;-><init>(Lcom/turntable/player/TalkService;)V
    invoke-virtual {v0}, Lcom/turntable/player/TalkPoll;->start()V
    return-void
.end method

.method public onDestroy()V
    .locals 1
    iget-object v0, p0, Lcom/turntable/player/TalkService;->h:Landroid/os/Handler;
    if-eqz v0, :n
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    :n
    const/4 v0, 0x0
    sput-object v0, Lcom/turntable/player/TalkService;->inst:Lcom/turntable/player/TalkService;
    invoke-super {p0}, Landroid/app/Service;->onDestroy()V
    return-void
.end method

.method private fg()V
    .locals 6
    :try_start
    const-string v0, "notification"
    invoke-virtual {p0, v0}, Lcom/turntable/player/TalkService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/app/NotificationManager;
    new-instance v1, Landroid/app/NotificationChannel;
    const-string v2, "talkwait"
    const-string v3, "해피톡 알림 대기"
    const/4 v4, 0x1
    invoke-direct {v1, v2, v3, v4}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/app/NotificationChannel;->setShowBadge(Z)V
    invoke-virtual {v1, v2, v2}, Landroid/app/NotificationChannel;->setSound(Landroid/net/Uri;Landroid/media/AudioAttributes;)V
    invoke-virtual {v0, v1}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V
    new-instance v1, Landroid/app/Notification$Builder;
    const-string v2, "talkwait"
    invoke-direct {v1, p0, v2}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V
    invoke-virtual {p0}, Lcom/turntable/player/TalkService;->getResources()Landroid/content/res/Resources;
    move-result-object v2
    const-string v3, "ic_note"
    const-string v4, "drawable"
    invoke-virtual {p0}, Lcom/turntable/player/TalkService;->getPackageName()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v2, v3, v4, v5}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v2
    invoke-virtual {v1, v2}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;
    const-string v2, "해피톡 알림 대기 중"
    invoke-virtual {v1, v2}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    const-string v2, "새 메시지가 오면 알려 드려요 · 해피톡 › 내 정보에서 끌 수 있어요"
    invoke-virtual {v1, v2}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/app/Notification$Builder;->setOngoing(Z)Landroid/app/Notification$Builder;
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/app/Notification$Builder;->setShowWhen(Z)Landroid/app/Notification$Builder;
    new-instance v2, Landroid/content/Intent;
    const-class v3, Lcom/turntable/player/MainActivity;
    invoke-direct {v2, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    const/4 v3, 0x0
    const/high16 v4, 0x4000000
    invoke-static {p0, v3, v2, v4}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/app/Notification$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroid/app/Notification$Builder;
    invoke-virtual {v1}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object v1
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x22
    const/16 v4, 0x2b
    if-lt v2, v3, :old
    const/16 v2, 0x200
    invoke-virtual {p0, v4, v1, v2}, Lcom/turntable/player/TalkService;->startForeground(ILandroid/app/Notification;I)V
    goto :done
    :old
    invoke-virtual {p0, v4, v1}, Lcom/turntable/player/TalkService;->startForeground(ILandroid/app/Notification;)V
    :done
    nop
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    :e
    return-void
.end method

# 설정(on)에 맞춰 켜거나 끈다
.method public static apply(Landroid/content/Context;)V
    .locals 4
    :try_start
    const-string v0, "talk"
    const/4 v1, 0x0
    invoke-virtual {p0, v0, v1}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0
    const-string v2, "on"
    invoke-interface {v0, v2, v1}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v0
    new-instance v2, Landroid/content/Intent;
    const-class v3, Lcom/turntable/player/TalkService;
    invoke-direct {v2, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    if-eqz v0, :off
    invoke-virtual {p0, v2}, Landroid/content/Context;->startForegroundService(Landroid/content/Intent;)Landroid/content/ComponentName;
    goto :out
    :off
    invoke-virtual {p0, v2}, Landroid/content/Context;->stopService(Landroid/content/Intent;)Z
    :out
    nop
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    :e
    return-void
.end method
