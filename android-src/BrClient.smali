.class public Lcom/turntable/player/BrClient;
.super Landroid/webkit/WebViewClient;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/webkit/WebViewClient;-><init>()V
    return-void
.end method

.method public onPageStarted(Landroid/webkit/WebView;Ljava/lang/String;Landroid/graphics/Bitmap;)V
    .locals 3
    const-string v0, "start"
    const/4 v1, 0x0
    const/4 v2, 0x0
    invoke-static {v0, p2, v1, v2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

.method public onPageFinished(Landroid/webkit/WebView;Ljava/lang/String;)V
    .locals 3
    const-string v0, "finish"
    invoke-virtual {p1}, Landroid/webkit/WebView;->getTitle()Ljava/lang/String;
    move-result-object v1
    const/16 v2, 0x64
    invoke-static {v0, p2, v1, v2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

.method public doUpdateVisitedHistory(Landroid/webkit/WebView;Ljava/lang/String;Z)V
    .locals 3
    const-string v0, "hist"
    invoke-virtual {p1}, Landroid/webkit/WebView;->getTitle()Ljava/lang/String;
    move-result-object v1
    const/4 v2, -0x1
    invoke-static {v0, p2, v1, v2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

# http(s)는 브라우저 안에서, 그 밖(앱 링크·전화·intent://)은 해당 앱으로
.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Z
    .locals 5
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;
    move-result-object v0
    invoke-virtual {v0}, Landroid/net/Uri;->getScheme()Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :no
    const-string v2, "http"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :no
    const-string v2, "https"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :no
    const-string v2, "about"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :no
    const-string v2, "data"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :no
    const-string v2, "blob"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :no
    :try_start
    const-string v2, "intent"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :view
    invoke-virtual {v0}, Landroid/net/Uri;->toString()Ljava/lang/String;
    move-result-object v2
    const/4 v3, 0x1
    invoke-static {v2, v3}, Landroid/content/Intent;->parseUri(Ljava/lang/String;I)Landroid/content/Intent;
    move-result-object v2
    goto :go
    :view
    new-instance v2, Landroid/content/Intent;
    const-string v3, "android.intent.action.VIEW"
    invoke-direct {v2, v3, v0}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V
    :go
    const/high16 v3, 0x10000000
    invoke-virtual {v2, v3}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    sget-object v3, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    invoke-virtual {v3, v2}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :caught
    :caught
    const/4 v0, 0x1
    return v0
    :no
    const/4 v0, 0x0
    return v0
.end method
