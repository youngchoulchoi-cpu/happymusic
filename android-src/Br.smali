.class public Lcom/turntable/player/Br;
.super Ljava/lang/Object;

# 앱 안 인터넷 브라우저: 두 번째 WebView를 화면에 겹쳐 띄운다 (위 주소창·아래 버튼은 HTML)
.field public static w:Landroid/webkit/WebView;
.field public static preq:Landroid/webkit/PermissionRequest;
.field public static geoCb:Landroid/webkit/GeolocationPermissions$Callback;
.field public static geoOrigin:Ljava/lang/String;
.field public static waiting:Z
.field public static cv:Landroid/view/View;
.field public static cvCb:Landroid/webkit/WebChromeClient$CustomViewCallback;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static emit(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    .locals 5
    :try_start
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct {v0}, Lorg/json/JSONObject;-><init>()V
    const-string v1, "e"
    invoke-virtual {v0, v1, p0}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    if-eqz p1, :nourl
    const-string v1, "u"
    invoke-virtual {v0, v1, p1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :nourl
    if-eqz p2, :notitle
    const-string v1, "t"
    invoke-virtual {v0, v1, p2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :notitle
    const-string v1, "p"
    invoke-virtual {v0, v1, p3}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;
    sget-object v2, Lcom/turntable/player/Br;->w:Landroid/webkit/WebView;
    if-eqz v2, :now
    invoke-virtual {v2}, Landroid/webkit/WebView;->canGoBack()Z
    move-result v3
    const-string v1, "b"
    invoke-virtual {v0, v1, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    invoke-virtual {v2}, Landroid/webkit/WebView;->canGoForward()Z
    move-result v3
    const-string v1, "f"
    invoke-virtual {v0, v1, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;
    :now
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "window.onBrowser&&onBrowser("
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, ")"
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    sget-object v2, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-eqz v2, :end
    invoke-virtual {v2, v1}, Lcom/turntable/player/MainActivity;->runJs(Ljava/lang/String;)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :end
    :end
    return-void
.end method

.method public static open(Ljava/lang/String;II)V
    .locals 8
    sget-object v0, Lcom/turntable/player/Br;->w:Landroid/webkit/WebView;
    if-nez v0, :have
    sget-object v1, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-nez v1, :mk
    return-void
    :mk
    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, v1}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v2
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setSupportZoom(Z)V
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setBuiltInZoomControls(Z)V
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setGeolocationEnabled(Z)V
    invoke-virtual {v2, v3}, Landroid/webkit/WebSettings;->setJavaScriptCanOpenWindowsAutomatically(Z)V
    const/4 v4, 0x0
    invoke-virtual {v2, v4}, Landroid/webkit/WebSettings;->setDisplayZoomControls(Z)V
    invoke-virtual {v2}, Landroid/webkit/WebSettings;->getUserAgentString()Ljava/lang/String;
    move-result-object v5
    const-string v6, "; wv"
    const-string v7, ""
    invoke-virtual {v5, v6, v7}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v2, v5}, Landroid/webkit/WebSettings;->setUserAgentString(Ljava/lang/String;)V
    new-instance v2, Lcom/turntable/player/BrClient;
    invoke-direct {v2}, Lcom/turntable/player/BrClient;-><init>()V
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V
    new-instance v2, Lcom/turntable/player/BrChrome;
    invoke-direct {v2}, Lcom/turntable/player/BrChrome;-><init>()V
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->setWebChromeClient(Landroid/webkit/WebChromeClient;)V
    new-instance v2, Lcom/turntable/player/BrDl;
    invoke-direct {v2}, Lcom/turntable/player/BrDl;-><init>()V
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->setDownloadListener(Landroid/webkit/DownloadListener;)V
    invoke-static {}, Landroid/webkit/CookieManager;->getInstance()Landroid/webkit/CookieManager;
    move-result-object v2
    invoke-virtual {v2, v0, v3}, Landroid/webkit/CookieManager;->setAcceptThirdPartyCookies(Landroid/webkit/WebView;Z)V
    const v2, 0x1020002
    invoke-virtual {v1, v2}, Lcom/turntable/player/MainActivity;->findViewById(I)Landroid/view/View;
    move-result-object v2
    check-cast v2, Landroid/view/ViewGroup;
    new-instance v5, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v6, -0x1
    invoke-direct {v5, v6, v6}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v2, v0, v5}, Landroid/view/ViewGroup;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V
    sput-object v0, Lcom/turntable/player/Br;->w:Landroid/webkit/WebView;
    :have
    invoke-static {p1, p2}, Lcom/turntable/player/Br;->bounds(II)V
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setVisibility(I)V
    if-eqz p0, :done
    invoke-virtual {p0}, Ljava/lang/String;->length()I
    move-result v1
    if-eqz v1, :done
    invoke-virtual {v0, p0}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    :done
    return-void
.end method

.method public static bounds(II)V
    .locals 4
    sget-object v0, Lcom/turntable/player/Br;->w:Landroid/webkit/WebView;
    if-eqz v0, :r
    sget-object v1, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-eqz v1, :r
    invoke-virtual {v1}, Lcom/turntable/player/MainActivity;->getResources()Landroid/content/res/Resources;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v1
    iget v1, v1, Landroid/util/DisplayMetrics;->density:F
    invoke-virtual {v0}, Landroid/webkit/WebView;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;
    move-result-object v2
    check-cast v2, Landroid/view/ViewGroup$MarginLayoutParams;
    int-to-float v3, p0
    mul-float/2addr v3, v1
    float-to-int v3, v3
    iput v3, v2, Landroid/view/ViewGroup$MarginLayoutParams;->topMargin:I
    int-to-float v3, p1
    mul-float/2addr v3, v1
    float-to-int v3, v3
    iput v3, v2, Landroid/view/ViewGroup$MarginLayoutParams;->bottomMargin:I
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    :r
    return-void
.end method

.method public static load(Ljava/lang/String;)V
    .locals 1
    sget-object v0, Lcom/turntable/player/Br;->w:Landroid/webkit/WebView;
    if-eqz v0, :r
    if-eqz p0, :r
    invoke-virtual {v0, p0}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    :r
    return-void
.end method

# 2 뒤로 3 앞으로 4 새로고침 5 멈춤 6 숨김 7 보임 9 닫기
.method public static cmd(I)V
    .locals 3
    sget-object v0, Lcom/turntable/player/Br;->w:Landroid/webkit/WebView;
    if-eqz v0, :r
    const/4 v1, 0x2
    if-ne p0, v1, :c3
    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z
    move-result v2
    if-eqz v2, :r
    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V
    goto :r
    :c3
    const/4 v1, 0x3
    if-ne p0, v1, :c4
    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoForward()Z
    move-result v2
    if-eqz v2, :r
    invoke-virtual {v0}, Landroid/webkit/WebView;->goForward()V
    goto :r
    :c4
    const/4 v1, 0x4
    if-ne p0, v1, :c5
    invoke-virtual {v0}, Landroid/webkit/WebView;->reload()V
    goto :r
    :c5
    const/4 v1, 0x5
    if-ne p0, v1, :c6
    invoke-virtual {v0}, Landroid/webkit/WebView;->stopLoading()V
    goto :r
    :c6
    const/4 v1, 0x6
    if-ne p0, v1, :c7
    const/16 v2, 0x8
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->setVisibility(I)V
    goto :r
    :c7
    const/4 v1, 0x7
    if-ne p0, v1, :c9
    const/4 v2, 0x0
    invoke-virtual {v0, v2}, Landroid/webkit/WebView;->setVisibility(I)V
    goto :r
    :c9
    const/16 v1, 0x9
    if-ne p0, v1, :r
    invoke-virtual {v0}, Landroid/webkit/WebView;->getParent()Landroid/view/ViewParent;
    move-result-object v1
    instance-of v2, v1, Landroid/view/ViewGroup;
    if-eqz v2, :nd
    check-cast v1, Landroid/view/ViewGroup;
    invoke-virtual {v1, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V
    :nd
    invoke-virtual {v0}, Landroid/webkit/WebView;->destroy()V
    const/4 v1, 0x0
    sput-object v1, Lcom/turntable/player/Br;->w:Landroid/webkit/WebView;
    :r
    return-void
.end method

.method static has(Ljava/lang/String;)Z
    .locals 2
    sget-object v0, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-eqz v0, :no
    invoke-virtual {v0, p0}, Lcom/turntable/player/MainActivity;->checkSelfPermission(Ljava/lang/String;)I
    move-result v1
    if-nez v1, :no
    const/4 v0, 0x1
    return v0
    :no
    const/4 v0, 0x0
    return v0
.end method

.method static need(Ljava/util/ArrayList;Ljava/lang/String;)V
    .locals 1
    invoke-static {p1}, Lcom/turntable/player/Br;->has(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :r
    invoke-virtual {p0, p1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :r
    return-void
.end method

.method static wants(Ljava/lang/String;)Z
    .locals 5
    sget-object v0, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    if-eqz v0, :no
    invoke-virtual {v0}, Landroid/webkit/PermissionRequest;->getResources()[Ljava/lang/String;
    move-result-object v0
    array-length v1, v0
    const/4 v2, 0x0
    :loop
    if-ge v2, v1, :no
    aget-object v3, v0, v2
    invoke-virtual {p0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :yes
    add-int/lit8 v2, v2, 0x1
    goto :loop
    :yes
    const/4 v0, 0x1
    return v0
    :no
    const/4 v0, 0x0
    return v0
.end method

# 사용자가 앱 화면에서 허용/차단을 고른 뒤 (허용이면 필요한 안드로이드 권한부터 받는다)
.method public static permReply(Z)V
    .locals 5
    if-nez p0, :allow
    sget-object v0, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    if-eqz v0, :g
    invoke-virtual {v0}, Landroid/webkit/PermissionRequest;->deny()V
    const/4 v1, 0x0
    sput-object v1, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    :g
    sget-object v0, Lcom/turntable/player/Br;->geoCb:Landroid/webkit/GeolocationPermissions$Callback;
    if-eqz v0, :r
    sget-object v1, Lcom/turntable/player/Br;->geoOrigin:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-interface {v0, v1, v2, v2}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V
    const/4 v1, 0x0
    sput-object v1, Lcom/turntable/player/Br;->geoCb:Landroid/webkit/GeolocationPermissions$Callback;
    :r
    return-void
    :allow
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    const-string v1, "android.webkit.resource.VIDEO_CAPTURE"
    invoke-static {v1}, Lcom/turntable/player/Br;->wants(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :na
    const-string v1, "android.permission.CAMERA"
    invoke-static {v0, v1}, Lcom/turntable/player/Br;->need(Ljava/util/ArrayList;Ljava/lang/String;)V
    :na
    const-string v1, "android.webkit.resource.AUDIO_CAPTURE"
    invoke-static {v1}, Lcom/turntable/player/Br;->wants(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :ng
    const-string v1, "android.permission.RECORD_AUDIO"
    invoke-static {v0, v1}, Lcom/turntable/player/Br;->need(Ljava/util/ArrayList;Ljava/lang/String;)V
    :ng
    sget-object v1, Lcom/turntable/player/Br;->geoCb:Landroid/webkit/GeolocationPermissions$Callback;
    if-eqz v1, :chk
    const-string v1, "android.permission.ACCESS_FINE_LOCATION"
    invoke-static {v1}, Lcom/turntable/player/Br;->has(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :chk
    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    const-string v1, "android.permission.ACCESS_COARSE_LOCATION"
    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :chk
    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I
    move-result v1
    if-nez v1, :ask
    invoke-static {}, Lcom/turntable/player/Br;->grantNow()V
    return-void
    :ask
    sget-object v2, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-nez v2, :go
    invoke-static {}, Lcom/turntable/player/Br;->grantNow()V
    return-void
    :go
    const/4 v3, 0x1
    sput-boolean v3, Lcom/turntable/player/Br;->waiting:Z
    new-array v3, v1, [Ljava/lang/String;
    invoke-virtual {v0, v3}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    move-result-object v3
    check-cast v3, [Ljava/lang/String;
    const/16 v4, 0x4d
    invoke-virtual {v2, v3, v4}, Lcom/turntable/player/MainActivity;->requestPermissions([Ljava/lang/String;I)V
    return-void
.end method

.method public static afterPerms()V
    .locals 1
    sget-boolean v0, Lcom/turntable/player/Br;->waiting:Z
    if-eqz v0, :r
    const/4 v0, 0x0
    sput-boolean v0, Lcom/turntable/player/Br;->waiting:Z
    :try_start
    invoke-static {}, Lcom/turntable/player/Br;->grantNow()V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :r
    :r
    return-void
.end method

# 안드로이드 권한이 있는 것만 웹페이지에 넘겨준다
.method static grantNow()V
    .locals 6
    sget-object v0, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    if-eqz v0, :geo
    new-instance v1, Ljava/util/ArrayList;
    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V
    invoke-virtual {v0}, Landroid/webkit/PermissionRequest;->getResources()[Ljava/lang/String;
    move-result-object v2
    array-length v3, v2
    const/4 v4, 0x0
    :loop
    if-ge v4, v3, :done
    aget-object v5, v2, v4
    const-string v0, "android.webkit.resource.VIDEO_CAPTURE"
    invoke-virtual {v0, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :notcam
    const-string v0, "android.permission.CAMERA"
    invoke-static {v0}, Lcom/turntable/player/Br;->has(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :next
    goto :add
    :notcam
    const-string v0, "android.webkit.resource.AUDIO_CAPTURE"
    invoke-virtual {v0, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :add
    const-string v0, "android.permission.RECORD_AUDIO"
    invoke-static {v0}, Lcom/turntable/player/Br;->has(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :next
    :add
    invoke-virtual {v1, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :next
    add-int/lit8 v4, v4, 0x1
    goto :loop
    :done
    sget-object v0, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I
    move-result v3
    if-nez v3, :grant
    invoke-virtual {v0}, Landroid/webkit/PermissionRequest;->deny()V
    goto :clr
    :grant
    new-array v3, v3, [Ljava/lang/String;
    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    move-result-object v3
    check-cast v3, [Ljava/lang/String;
    invoke-virtual {v0, v3}, Landroid/webkit/PermissionRequest;->grant([Ljava/lang/String;)V
    :clr
    const/4 v0, 0x0
    sput-object v0, Lcom/turntable/player/Br;->preq:Landroid/webkit/PermissionRequest;
    :geo
    sget-object v0, Lcom/turntable/player/Br;->geoCb:Landroid/webkit/GeolocationPermissions$Callback;
    if-eqz v0, :r
    const-string v1, "android.permission.ACCESS_FINE_LOCATION"
    invoke-static {v1}, Lcom/turntable/player/Br;->has(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :ok
    const-string v1, "android.permission.ACCESS_COARSE_LOCATION"
    invoke-static {v1}, Lcom/turntable/player/Br;->has(Ljava/lang/String;)Z
    move-result v2
    :ok
    sget-object v1, Lcom/turntable/player/Br;->geoOrigin:Ljava/lang/String;
    const/4 v3, 0x0
    invoke-interface {v0, v1, v2, v3}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V
    const/4 v0, 0x0
    sput-object v0, Lcom/turntable/player/Br;->geoCb:Landroid/webkit/GeolocationPermissions$Callback;
    :r
    return-void
.end method

.method public static showCv(Landroid/view/View;Landroid/webkit/WebChromeClient$CustomViewCallback;)V
    .locals 4
    sget-object v0, Lcom/turntable/player/Br;->cv:Landroid/view/View;
    if-eqz v0, :fresh
    invoke-static {}, Lcom/turntable/player/Br;->hideCv()Z
    :fresh
    sget-object v0, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-nez v0, :go
    invoke-interface {p1}, Landroid/webkit/WebChromeClient$CustomViewCallback;->onCustomViewHidden()V
    return-void
    :go
    :try_start
    const v1, 0x1020002
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Landroid/view/ViewGroup;
    const/high16 v2, -0x1000000
    invoke-virtual {p0, v2}, Landroid/view/View;->setBackgroundColor(I)V
    new-instance v2, Landroid/widget/FrameLayout$LayoutParams;
    const/4 v3, -0x1
    invoke-direct {v2, v3, v3}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v1, p0, v2}, Landroid/view/ViewGroup;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V
    sput-object p0, Lcom/turntable/player/Br;->cv:Landroid/view/View;
    sput-object p1, Lcom/turntable/player/Br;->cvCb:Landroid/webkit/WebChromeClient$CustomViewCallback;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getWindow()Landroid/view/Window;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    const/16 v2, 0x1706
    invoke-virtual {v1, v2}, Landroid/view/View;->setSystemUiVisibility(I)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    return-void
    :e
    invoke-interface {p1}, Landroid/webkit/WebChromeClient$CustomViewCallback;->onCustomViewHidden()V
    return-void
.end method

# 웹이 전체 화면을 끝냈을 때: 보기만 치운다
.method public static removeCv()V
    .locals 3
    sget-object v0, Lcom/turntable/player/Br;->cv:Landroid/view/View;
    if-eqz v0, :r
    :try_start
    invoke-virtual {v0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v1
    instance-of v2, v1, Landroid/view/ViewGroup;
    if-eqz v2, :np
    check-cast v1, Landroid/view/ViewGroup;
    invoke-virtual {v1, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V
    :np
    sget-object v1, Lcom/turntable/player/MainActivity;->inst:Lcom/turntable/player/MainActivity;
    if-eqz v1, :ns
    invoke-virtual {v1}, Lcom/turntable/player/MainActivity;->getWindow()Landroid/view/Window;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/view/View;->setSystemUiVisibility(I)V
    :ns
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :r
    :r
    const/4 v0, 0x0
    sput-object v0, Lcom/turntable/player/Br;->cv:Landroid/view/View;
    sput-object v0, Lcom/turntable/player/Br;->cvCb:Landroid/webkit/WebChromeClient$CustomViewCallback;
    return-void
.end method

# 뒤로 버튼: 전체 화면이면 먼저 빠져나온다
.method public static hideCv()Z
    .locals 2
    sget-object v0, Lcom/turntable/player/Br;->cv:Landroid/view/View;
    if-nez v0, :has
    const/4 v0, 0x0
    return v0
    :has
    sget-object v1, Lcom/turntable/player/Br;->cvCb:Landroid/webkit/WebChromeClient$CustomViewCallback;
    invoke-static {}, Lcom/turntable/player/Br;->removeCv()V
    if-eqz v1, :d
    :try_start
    invoke-interface {v1}, Landroid/webkit/WebChromeClient$CustomViewCallback;->onCustomViewHidden()V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :d
    :d
    const/4 v0, 0x1
    return v0
.end method
