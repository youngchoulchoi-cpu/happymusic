.class public Lcom/turntable/player/Br;
.super Ljava/lang/Object;

# 앱 안 인터넷 브라우저: 두 번째 WebView를 화면에 겹쳐 띄운다 (위 주소창·아래 버튼은 HTML)
.field public static w:Landroid/webkit/WebView;

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
