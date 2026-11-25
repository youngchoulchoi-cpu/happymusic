.class public Lcom/turntable/player/BrChrome;
.super Landroid/webkit/WebChromeClient;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/webkit/WebChromeClient;-><init>()V
    return-void
.end method

.method public onProgressChanged(Landroid/webkit/WebView;I)V
    .locals 3
    const-string v0, "prog"
    invoke-virtual {p1}, Landroid/webkit/WebView;->getUrl()Ljava/lang/String;
    move-result-object v1
    const/4 v2, 0x0
    invoke-static {v0, v1, v2, p2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

.method public onReceivedTitle(Landroid/webkit/WebView;Ljava/lang/String;)V
    .locals 3
    const-string v0, "title"
    invoke-virtual {p1}, Landroid/webkit/WebView;->getUrl()Ljava/lang/String;
    move-result-object v1
    const/4 v2, -0x1
    invoke-static {v0, v1, p2, v2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method
