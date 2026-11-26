.class final Lcom/turntable/player/MainActivity$1;
.super Landroid/webkit/WebChromeClient;

.field final a:Lcom/turntable/player/MainActivity;

.method constructor <init>(Lcom/turntable/player/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Landroid/webkit/WebChromeClient;-><init>()V
    iput-object p1, p0, Lcom/turntable/player/MainActivity$1;->a:Lcom/turntable/player/MainActivity;
    return-void
.end method

.method public onShowFileChooser(Landroid/webkit/WebView;Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    .locals 4
    iget-object v0, p0, Lcom/turntable/player/MainActivity$1;->a:Lcom/turntable/player/MainActivity;
    :try_start
    invoke-virtual {p3}, Landroid/webkit/WebChromeClient$FileChooserParams;->createIntent()Landroid/content/Intent;
    move-result-object v1
    invoke-virtual {p3}, Landroid/webkit/WebChromeClient$FileChooserParams;->getMode()I
    move-result v2
    if-eqz v2, :one
    const-string v2, "android.intent.extra.ALLOW_MULTIPLE"
    const/4 v3, 0x1
    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;
    :one
    invoke-virtual {v0, p2, v1}, Lcom/turntable/player/MainActivity;->openPickerIntent(Landroid/webkit/ValueCallback;Landroid/content/Intent;)Z
    move-result v1
    return v1
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :old
    :old
    invoke-virtual {v0, p2}, Lcom/turntable/player/MainActivity;->openPicker(Landroid/webkit/ValueCallback;)Z
    move-result v1
    return v1
.end method

.method public onShowCustomView(Landroid/view/View;Landroid/webkit/WebChromeClient$CustomViewCallback;)V
    .locals 0
    invoke-static {p1, p2}, Lcom/turntable/player/Br;->showCv(Landroid/view/View;Landroid/webkit/WebChromeClient$CustomViewCallback;)V
    return-void
.end method

.method public onHideCustomView()V
    .locals 0
    invoke-static {}, Lcom/turntable/player/Br;->removeCv()V
    return-void
.end method
