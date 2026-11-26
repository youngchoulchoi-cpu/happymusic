.class public Lcom/turntable/player/Bridge;
.super Ljava/lang/Object;

.field final a:Lcom/turntable/player/MainActivity;
.field private dlId:J

.method public constructor <init>(Lcom/turntable/player/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    return-void
.end method

.method public hasPerm()Z
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->permName()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->checkSelfPermission(Ljava/lang/String;)I
    move-result v0
    if-nez v0, :no
    const/4 v0, 0x1
    return v0
    :no
    const/4 v0, 0x0
    return v0
.end method

.method public requestPerm()V
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0, v0}, Lcom/turntable/player/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

.method public openSettings()V
    .locals 5
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    :try_start
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.settings.APPLICATION_DETAILS_SETTINGS"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v2, "package"
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageName()Ljava/lang/String;
    move-result-object v3
    const/4 v4, 0x0
    invoke-static {v2, v3, v4}, Landroid/net/Uri;->fromParts(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;
    const/high16 v2, 0x10000000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :done
    :done
    return-void
.end method

.method public takeOpened()Ljava/lang/String;
    .locals 9
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    iget-object v1, v0, Lcom/turntable/player/MainActivity;->pending:Landroid/net/Uri;
    if-nez v1, :has
    const-string v0, ""
    return-object v0
    :has
    const/4 v2, 0x0
    iput-object v2, v0, Lcom/turntable/player/MainActivity;->pending:Landroid/net/Uri;
    new-instance v8, Lorg/json/JSONObject;
    invoke-direct {v8}, Lorg/json/JSONObject;-><init>()V
    :try_start
    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "u"
    invoke-virtual {v8, v3, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2
    const/4 v3, 0x1
    new-array v4, v3, [Ljava/lang/String;
    const/4 v3, 0x0
    const-string v5, "_display_name"
    aput-object v5, v4, v3
    move-object v3, v1
    const/4 v5, 0x0
    const/4 v6, 0x0
    const/4 v7, 0x0
    invoke-virtual/range {v2 .. v7}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v2
    if-eqz v2, :done
    invoke-interface {v2}, Landroid/database/Cursor;->moveToFirst()Z
    move-result v3
    if-eqz v3, :closeit
    const/4 v3, 0x0
    invoke-interface {v2, v3}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v3
    const-string v4, "n"
    invoke-virtual {v8, v4, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :closeit
    invoke-interface {v2}, Landroid/database/Cursor;->close()V
    :done
    nop
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :out
    :out
    invoke-virtual {v8}, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public scan()Ljava/lang/String;
    .locals 12
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    new-instance v0, Lorg/json/JSONArray;
    invoke-direct {v0}, Lorg/json/JSONArray;-><init>()V
    :try_start
    iget-object v1, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v1}, Lcom/turntable/player/MainActivity;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    sget-object v2, Landroid/provider/MediaStore$Audio$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;
    const/4 v3, 0x7
    new-array v3, v3, [Ljava/lang/String;
    const/4 v4, 0x0
    const-string v5, "_id"
    aput-object v5, v3, v4
    const/4 v4, 0x1
    const-string v5, "title"
    aput-object v5, v3, v4
    const/4 v4, 0x2
    const-string v5, "artist"
    aput-object v5, v3, v4
    const/4 v4, 0x3
    const-string v5, "album"
    aput-object v5, v3, v4
    const/4 v4, 0x4
    const-string v5, "duration"
    aput-object v5, v3, v4
    const/4 v4, 0x5
    const-string v5, "date_added"
    aput-object v5, v3, v4
    const/4 v4, 0x6
    const-string v5, "_data"
    aput-object v5, v3, v4
    const/4 v4, 0x0
    const/4 v5, 0x0
    const-string v6, "date_added DESC"
    invoke-virtual/range {v1 .. v6}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v1
    if-eqz v1, :end
    :loop
    invoke-interface {v1}, Landroid/database/Cursor;->moveToNext()Z
    move-result v3
    if-eqz v3, :close
    new-instance v3, Lorg/json/JSONObject;
    invoke-direct {v3}, Lorg/json/JSONObject;-><init>()V
    const/4 v4, 0x0
    invoke-interface {v1, v4}, Landroid/database/Cursor;->getLong(I)J
    move-result-wide v4
    invoke-static {v2, v4, v5}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;
    move-result-object v6
    invoke-virtual {v6}, Landroid/net/Uri;->toString()Ljava/lang/String;
    move-result-object v6
    const-string v7, "u"
    invoke-virtual {v3, v7, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const/4 v6, 0x1
    invoke-interface {v1, v6}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v6
    const-string v7, "t"
    invoke-virtual {v3, v7, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const/4 v6, 0x2
    invoke-interface {v1, v6}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v6
    const-string v7, "a"
    invoke-virtual {v3, v7, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const/4 v6, 0x3
    invoke-interface {v1, v6}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v6
    const-string v7, "al"
    invoke-virtual {v3, v7, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const/4 v6, 0x4
    invoke-interface {v1, v6}, Landroid/database/Cursor;->getLong(I)J
    move-result-wide v6
    const-string v8, "d"
    invoke-virtual {v3, v8, v6, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;
    const/4 v6, 0x5
    invoke-interface {v1, v6}, Landroid/database/Cursor;->getLong(I)J
    move-result-wide v6
    const-string v8, "da"
    invoke-virtual {v3, v8, v6, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;
    const/4 v6, 0x6
    invoke-interface {v1, v6}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v6
    const-string v7, "p"
    invoke-virtual {v3, v7, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    invoke-virtual {v0, v3}, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    goto :loop
    :close
    invoke-interface {v1}, Landroid/database/Cursor;->close()V
    :end
    nop
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :out
    :out
    invoke-virtual {v0}, Lorg/json/JSONArray;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public setState(ZLjava/lang/String;Ljava/lang/String;)V
    .locals 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    sget-object v0, Lcom/turntable/player/PlaybackService;->inst:Lcom/turntable/player/PlaybackService;
    if-eqz v0, :start
    invoke-virtual {v0, p1, p2, p3}, Lcom/turntable/player/PlaybackService;->update(ZLjava/lang/String;Ljava/lang/String;)V
    goto :done
    :start
    if-eqz p1, :done
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Landroid/content/Intent;
    const-class v2, Lcom/turntable/player/PlaybackService;
    invoke-direct {v1, v0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    const-string v2, "p"
    invoke-virtual {v1, v2, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;
    const-string v2, "t"
    invoke-virtual {v1, v2, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const-string v2, "a"
    invoke-virtual {v1, v2, p3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->startForegroundService(Landroid/content/Intent;)Landroid/content/ComponentName;
    :done
    nop
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :out
    :out
    return-void
.end method

.method public deepScan()V
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    new-instance v0, Ljava/lang/Thread;
    new-instance v1, Lcom/turntable/player/DeepScan;
    iget-object v2, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-direct {v1, v2}, Lcom/turntable/player/DeepScan;-><init>(Lcom/turntable/player/MainActivity;)V
    invoke-direct {v0, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V
    invoke-virtual {v0}, Ljava/lang/Thread;->start()V
    return-void
.end method

.method public meta(Ljava/lang/String;)Ljava/lang/String;
    .locals 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct {v0}, Lorg/json/JSONObject;-><init>()V
    new-instance v1, Landroid/media/MediaMetadataRetriever;
    invoke-direct {v1}, Landroid/media/MediaMetadataRetriever;-><init>()V
    :try_start
    invoke-virtual {v1, p1}, Landroid/media/MediaMetadataRetriever;->setDataSource(Ljava/lang/String;)V
    const/4 v2, 0x7
    invoke-virtual {v1, v2}, Landroid/media/MediaMetadataRetriever;->extractMetadata(I)Ljava/lang/String;
    move-result-object v2
    const-string v3, "t"
    invoke-virtual {v0, v3, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const/4 v2, 0x2
    invoke-virtual {v1, v2}, Landroid/media/MediaMetadataRetriever;->extractMetadata(I)Ljava/lang/String;
    move-result-object v2
    const-string v3, "a"
    invoke-virtual {v0, v3, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/media/MediaMetadataRetriever;->extractMetadata(I)Ljava/lang/String;
    move-result-object v2
    const-string v3, "al"
    invoke-virtual {v0, v3, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    const/16 v2, 0x9
    invoke-virtual {v1, v2}, Landroid/media/MediaMetadataRetriever;->extractMetadata(I)Ljava/lang/String;
    move-result-object v2
    const-string v3, "d"
    invoke-virtual {v0, v3, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :rel
    :rel
    :try_start2
    invoke-virtual {v1}, Landroid/media/MediaMetadataRetriever;->release()V
    :try_end2
    .catch Ljava/lang/Throwable; {:try_start2 .. :try_end2} :ret
    :ret
    invoke-virtual {v0}, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public mediaScan(Ljava/lang/String;)V
    .locals 5
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    new-instance v0, Lorg/json/JSONArray;
    invoke-direct {v0, p1}, Lorg/json/JSONArray;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0}, Lorg/json/JSONArray;->length()I
    move-result v1
    new-array v2, v1, [Ljava/lang/String;
    const/4 v3, 0x0
    :loop
    if-ge v3, v1, :go
    invoke-virtual {v0, v3}, Lorg/json/JSONArray;->getString(I)Ljava/lang/String;
    move-result-object v4
    aput-object v4, v2, v3
    add-int/lit8 v3, v3, 0x1
    goto :loop
    :go
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    const/4 v1, 0x0
    invoke-static {v0, v2, v1, v1}, Landroid/media/MediaScannerConnection;->scanFile(Landroid/content/Context;[Ljava/lang/String;[Ljava/lang/String;Landroid/media/MediaScannerConnection$OnScanCompletedListener;)V
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :out
    :out
    return-void
.end method

.method public sdk()I
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    return v0
.end method

.method public hasAllFiles()Z
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v1, 0x1e
    if-ge v0, v1, :new
    const/4 v0, 0x0
    return v0
    :new
    invoke-static {}, Landroid/os/Environment;->isExternalStorageManager()Z
    move-result v0
    return v0
.end method

.method public requestAllFiles()V
    .locals 5
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    :try_start
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v2, "package"
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageName()Ljava/lang/String;
    move-result-object v3
    const/4 v4, 0x0
    invoke-static {v2, v3, v4}, Landroid/net/Uri;->fromParts(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;
    const/high16 v2, 0x10000000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :fallback
    return-void
    :fallback
    :try_start2
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.settings.MANAGE_ALL_FILES_ACCESS_PERMISSION"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const/high16 v2, 0x10000000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end2
    .catch Ljava/lang/Throwable; {:try_start2 .. :try_end2} :out
    :out
    return-void
.end method

.method public isNight()Z
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getResources()Landroid/content/res/Resources;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;
    move-result-object v0
    iget v0, v0, Landroid/content/res/Configuration;->uiMode:I
    and-int/lit8 v0, v0, 0x30
    const/16 v1, 0x20
    if-ne v0, v1, :no
    const/4 v0, 0x1
    return v0
    :no
    const/4 v0, 0x0
    return v0
.end method

.method public setBars(Z)V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Lcom/turntable/player/BarTask;
    invoke-direct {v1, v0, p1}, Lcom/turntable/player/BarTask;-><init>(Lcom/turntable/player/MainActivity;Z)V
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

.method public appVersion()Ljava/lang/String;
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v1
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageName()Ljava/lang/String;
    move-result-object v2
    const/4 v0, 0x0
    invoke-virtual {v1, v2, v0}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;
    move-result-object v0
    iget-object v0, v0, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;
    return-object v0
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :fail
    :fail
    const-string v0, "0"
    return-object v0
.end method

.method public canInstall()Z
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/pm/PackageManager;->canRequestPackageInstalls()Z
    move-result v0
    return v0
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :fail
    :fail
    const/4 v0, 0x1
    return v0
.end method

.method public requestInstallPermission()V
    .locals 5
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.settings.MANAGE_UNKNOWN_APP_SOURCES"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v2, "package"
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageName()Ljava/lang/String;
    move-result-object v3
    const/4 v4, 0x0
    invoke-static {v2, v3, v4}, Landroid/net/Uri;->fromParts(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;
    const/high16 v2, 0x10000000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :out
    :out
    return-void
.end method

.method public downloadUpdate(Ljava/lang/String;)J
    .locals 6
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    sget-object v3, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;
    invoke-virtual {v0, v3}, Lcom/turntable/player/MainActivity;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v4
    if-eqz v4, :nodel
    new-instance v5, Ljava/io/File;
    const-string v1, "HappyMusic-update.apk"
    invoke-direct {v5, v4, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v5}, Ljava/io/File;->delete()Z
    :nodel
    const-string v1, "download"
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/app/DownloadManager;
    new-instance v2, Landroid/app/DownloadManager$Request;
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v4
    invoke-direct {v2, v4}, Landroid/app/DownloadManager$Request;-><init>(Landroid/net/Uri;)V
    const-string v4, "HappyMusic-update.apk"
    invoke-virtual {v2, v0, v3, v4}, Landroid/app/DownloadManager$Request;->setDestinationInExternalFilesDir(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/app/DownloadManager$Request;
    const-string v3, "application/vnd.android.package-archive"
    invoke-virtual {v2, v3}, Landroid/app/DownloadManager$Request;->setMimeType(Ljava/lang/String;)Landroid/app/DownloadManager$Request;
    const-string v3, "HappyMusic update"
    invoke-virtual {v2, v3}, Landroid/app/DownloadManager$Request;->setTitle(Ljava/lang/CharSequence;)Landroid/app/DownloadManager$Request;
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/app/DownloadManager$Request;->setNotificationVisibility(I)Landroid/app/DownloadManager$Request;
    invoke-virtual {v1, v2}, Landroid/app/DownloadManager;->enqueue(Landroid/app/DownloadManager$Request;)J
    move-result-wide v2
    iput-wide v2, p0, Lcom/turntable/player/Bridge;->dlId:J
    return-wide v2
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :fail
    :fail
    const-wide/16 v0, -0x1
    return-wide v0
.end method

.method public updateStatus()Ljava/lang/String;
    .locals 8
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-wide v0, p0, Lcom/turntable/player/Bridge;->dlId:J
    const-wide/16 v2, 0x0
    cmp-long v4, v0, v2
    if-lez v4, :none
    :try_start
    iget-object v2, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    const-string v3, "download"
    invoke-virtual {v2, v3}, Lcom/turntable/player/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Landroid/app/DownloadManager;
    new-instance v3, Landroid/app/DownloadManager$Query;
    invoke-direct {v3}, Landroid/app/DownloadManager$Query;-><init>()V
    const/4 v4, 0x1
    new-array v4, v4, [J
    const/4 v5, 0x0
    aput-wide v0, v4, v5
    invoke-virtual {v3, v4}, Landroid/app/DownloadManager$Query;->setFilterById([J)Landroid/app/DownloadManager$Query;
    invoke-virtual {v2, v3}, Landroid/app/DownloadManager;->query(Landroid/app/DownloadManager$Query;)Landroid/database/Cursor;
    move-result-object v3
    if-eqz v3, :none
    invoke-interface {v3}, Landroid/database/Cursor;->moveToFirst()Z
    move-result v4
    if-eqz v4, :closenone
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "status"
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v5
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getInt(I)I
    move-result v5
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v5, ","
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "bytes_so_far"
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v5
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getLong(I)J
    move-result-wide v6
    invoke-virtual {v4, v6, v7}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    const-string v5, ","
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "total_size"
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v5
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getLong(I)J
    move-result-wide v6
    invoke-virtual {v4, v6, v7}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    invoke-interface {v3}, Landroid/database/Cursor;->close()V
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
    :closenone
    invoke-interface {v3}, Landroid/database/Cursor;->close()V
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :none
    :none
    const-string v0, "none"
    return-object v0
.end method

.method public installUpdate()Z
    .locals 5
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    const-string v1, "download"
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/app/DownloadManager;
    iget-wide v2, p0, Lcom/turntable/player/Bridge;->dlId:J
    invoke-virtual {v1, v2, v3}, Landroid/app/DownloadManager;->getUriForDownloadedFile(J)Landroid/net/Uri;
    move-result-object v1
    if-eqz v1, :fail
    new-instance v2, Landroid/content/Intent;
    const-string v3, "android.intent.action.VIEW"
    invoke-direct {v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v3, "application/vnd.android.package-archive"
    invoke-virtual {v2, v1, v3}, Landroid/content/Intent;->setDataAndType(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;
    const v3, 0x10000001
    invoke-virtual {v2, v3}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v2}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    const/4 v0, 0x1
    return v0
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :fail
    :fail
    const/4 v0, 0x0
    return v0
.end method

.method public saveWeb(Ljava/lang/String;)Z
    .locals 5
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "web_tmp.html"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v2, Ljava/io/FileOutputStream;
    invoke-direct {v2, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const-string v3, "UTF-8"
    invoke-virtual {p1, v3}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/io/FileOutputStream;->write([B)V
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V
    new-instance v3, Ljava/io/File;
    const-string v4, "web_index.html"
    invoke-direct {v3, v0, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1, v3}, Ljava/io/File;->renameTo(Ljava/io/File;)Z
    move-result v0
    return v0
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :fail
    :fail
    const/4 v0, 0x0
    return v0
.end method

.method public resetWeb()V
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "web_index.html"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->delete()Z
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :out
    :out
    return-void
.end method

.method public bootOk()V
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    const-string v1, "hm"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Lcom/turntable/player/MainActivity;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v0
    const-string v1, "boot"
    const/4 v2, 0x0
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;
    move-result-object v0
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :out
    :out
    return-void
.end method

# ---------- 앱 안 인터넷 브라우저 ----------
.method public hasBrowser()Z
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    const/4 v0, 0x1
    return v0
.end method

.method public brOpen(Ljava/lang/String;II)V
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Lcom/turntable/player/BrTask;
    const/4 v2, 0x0
    invoke-direct {v1, v2, p1, p2, p3}, Lcom/turntable/player/BrTask;-><init>(ILjava/lang/String;II)V
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

.method public brLoad(Ljava/lang/String;)V
    .locals 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Lcom/turntable/player/BrTask;
    const/4 v2, 0x1
    const/4 v3, 0x0
    invoke-direct {v1, v2, p1, v3, v3}, Lcom/turntable/player/BrTask;-><init>(ILjava/lang/String;II)V
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

.method public brCmd(I)V
    .locals 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Lcom/turntable/player/BrTask;
    const/4 v2, 0x0
    const/4 v3, 0x0
    invoke-direct {v1, p1, v2, v3, v3}, Lcom/turntable/player/BrTask;-><init>(ILjava/lang/String;II)V
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

.method public brBounds(II)V
    .locals 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Lcom/turntable/player/BrTask;
    const/16 v2, 0x8
    const/4 v3, 0x0
    invoke-direct {v1, v2, v3, p1, p2}, Lcom/turntable/player/BrTask;-><init>(ILjava/lang/String;II)V
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

.method public openExternal(Ljava/lang/String;)V
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.VIEW"
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v2
    invoke-direct {v0, v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V
    const/high16 v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    iget-object v1, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v1, v0}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    :e
    return-void
.end method

.method public brPerm(Z)V
    .locals 4
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    new-instance v1, Lcom/turntable/player/BrTask;
    const/16 v2, 0xa
    const/4 v3, 0x0
    if-eqz p1, :d
    const/4 v3, 0x1
    :d
    const/4 p1, 0x0
    invoke-direct {v1, v2, p1, v3, v3}, Lcom/turntable/player/BrTask;-><init>(ILjava/lang/String;II)V
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

# 다른 앱(업데이트 도우미 등)이 설치돼 있으면 버전, 없으면 ""
.method public pkgVersion(Ljava/lang/String;)Ljava/lang/String;
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v0
    const/4 v1, 0x0
    invoke-virtual {v0, p1, v1}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;
    move-result-object v0
    iget-object v0, v0, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;
    if-nez v0, :r
    const-string v0, "?"
    :r
    return-object v0
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :no
    :no
    const-string v0, ""
    return-object v0
.end method

.method public openApp(Ljava/lang/String;)Z
    .locals 3
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    :try_start
    iget-object v0, p0, Lcom/turntable/player/Bridge;->a:Lcom/turntable/player/MainActivity;
    invoke-virtual {v0}, Lcom/turntable/player/MainActivity;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v1
    invoke-virtual {v1, p1}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;
    move-result-object v1
    if-eqz v1, :no
    const/high16 v2, 0x10000000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Lcom/turntable/player/MainActivity;->startActivity(Landroid/content/Intent;)V
    const/4 v0, 0x1
    return v0
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :no
    :no
    const/4 v0, 0x0
    return v0
.end method
