.class public Lcom/turntable/player/BrDl;
.super Ljava/lang/Object;
.implements Landroid/webkit/DownloadListener;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# 웹에서 받은 파일은 '다운로드' 폴더로 (알림 표시)
.method public onDownloadStart(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;J)V
    .locals 6
    :try_start
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0
    new-instance v1, Landroid/app/DownloadManager$Request;
    invoke-direct {v1, v0}, Landroid/app/DownloadManager$Request;-><init>(Landroid/net/Uri;)V
    invoke-static {p1, p3, p4}, Landroid/webkit/URLUtil;->guessFileName(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    if-eqz p2, :noua
    const-string v3, "User-Agent"
    invoke-virtual {v1, v3, p2}, Landroid/app/DownloadManager$Request;->addRequestHeader(Ljava/lang/String;Ljava/lang/String;)Landroid/app/DownloadManager$Request;
    :noua
    invoke-static {}, Landroid/webkit/CookieManager;->getInstance()Landroid/webkit/CookieManager;
    move-result-object v3
    invoke-virtual {v3, p1}, Landroid/webkit/CookieManager;->getCookie(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :nock
    const-string v4, "Cookie"
    invoke-virtual {v1, v4, v3}, Landroid/app/DownloadManager$Request;->addRequestHeader(Ljava/lang/String;Ljava/lang/String;)Landroid/app/DownloadManager$Request;
    :nock
    const/4 v3, 0x1
    invoke-virtual {v1, v3}, Landroid/app/DownloadManager$Request;->setNotificationVisibility(I)Landroid/app/DownloadManager$Request;
    sget-object v3, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;
    invoke-virtual {v1, v3, v2}, Landroid/app/DownloadManager$Request;->setDestinationInExternalPublicDir(Ljava/lang/String;Ljava/lang/String;)Landroid/app/DownloadManager$Request;
    sget-object v3, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    const-string v4, "download"
    invoke-virtual {v3, v4}, Lcom/turntable/player/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/app/DownloadManager;
    invoke-virtual {v3, v1}, Landroid/app/DownloadManager;->enqueue(Landroid/app/DownloadManager$Request;)J
    move-result-wide v4
    const-string v3, "dl"
    const/4 v4, 0x0
    invoke-static {v3, p1, v2, v4}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :fail
    return-void
    :fail
    const-string v0, "dlfail"
    const/4 v1, 0x0
    const/4 v2, 0x0
    invoke-static {v0, p1, v1, v2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method
