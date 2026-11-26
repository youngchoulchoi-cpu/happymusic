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

.method public onShowFileChooser(Landroid/webkit/WebView;Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    .locals 3
    sget-object v0, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-eqz v0, :no
    :try_start
    invoke-virtual {p3}, Landroid/webkit/WebChromeClient$FileChooserParams;->createIntent()Landroid/content/Intent;
    move-result-object v1
    invoke-virtual {p3}, Landroid/webkit/WebChromeClient$FileChooserParams;->getMode()I
    move-result v2
    if-eqz v2, :one
    const-string v2, "android.intent.extra.ALLOW_MULTIPLE"
    const/4 p1, 0x1
    invoke-virtual {v1, v2, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;
    :one
    invoke-virtual {v0, p2, v1}, Lcom/turntable/player/MainActivity;->openPickerIntent(Landroid/webkit/ValueCallback;Landroid/content/Intent;)Z
    move-result v0
    return v0
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :no
    :no
    const/4 v0, 0x0
    return v0
.end method

.method public onPermissionRequest(Landroid/webkit/PermissionRequest;)V
    .locals 4
    sget-object v0, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    if-eqz v0, :fresh
    invoke-virtual {v0}, Landroid/webkit/PermissionRequest;->deny()V
    :fresh
    sput-object p1, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    const-string v0, "perm"
    invoke-virtual {p1}, Landroid/webkit/PermissionRequest;->getOrigin()Landroid/net/Uri;
    move-result-object v1
    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, ","
    invoke-virtual {p1}, Landroid/webkit/PermissionRequest;->getResources()[Ljava/lang/String;
    move-result-object v3
    invoke-static {v2, v3}, Landroid/text/TextUtils;->join(Ljava/lang/CharSequence;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v2
    const/4 v3, 0x0
    invoke-static {v0, v1, v2, v3}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

.method public onPermissionRequestCanceled(Landroid/webkit/PermissionRequest;)V
    .locals 3
    const/4 v0, 0x0
    sput-object v0, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    const-string v0, "permx"
    const/4 v1, 0x0
    const/4 v2, 0x0
    invoke-static {v0, v1, v1, v2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

.method public onGeolocationPermissionsShowPrompt(Ljava/lang/String;Landroid/webkit/GeolocationPermissions$Callback;)V
    .locals 3
    sput-object p1, Lcom/turntable/player/Br;->geoOrigin:Ljava/lang/String;
    sput-object p2, Lcom/turntable/player/Br;->geoCb:Landroid/webkit/GeolocationPermissions$Callback;
    const-string v0, "perm"
    const-string v1, "geo"
    const/4 v2, 0x0
    invoke-static {v0, p1, v1, v2}, Lcom/turntable/player/Br;->emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

.method public onGeolocationPermissionsHidePrompt()V
    .locals 1
    const/4 v0, 0x0
    sput-object v0, Lcom/turntable/player/Br;->geoCb:Landroid/webkit/GeolocationPermissions$Callback;
    return-void
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
