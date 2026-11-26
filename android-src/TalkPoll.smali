.class public Lcom/turntable/player/TalkPoll;
.super Ljava/lang/Thread;

# 한 번 확인하고 다음 확인 시각을 정한다 (대화가 뜸할수록 간격을 늘림)
.field public static code:I
.field svc:Lcom/turntable/player/TalkService;
.field me:Ljava/lang/String;

.method public constructor <init>(Lcom/turntable/player/TalkService;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V
    iput-object p1, p0, Lcom/turntable/player/TalkPoll;->svc:Lcom/turntable/player/TalkService;
    return-void
.end method

.method public static http(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .locals 6
    const/4 v0, 0x0
    sput v0, Lcom/turntable/player/TalkPoll;->code:I
    :try_start
    new-instance v0, Ljava/net/URL;
    invoke-direct {v0, p0}, Ljava/net/URL;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;
    move-result-object v0
    check-cast v0, Ljava/net/HttpURLConnection;
    const/16 v1, 0x3a98
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V
    const/16 v1, 0x4e20
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V
    const-string v1, "POST"
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setDoOutput(Z)V
    const-string v1, "apikey"
    invoke-virtual {v0, v1, p2}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V
    const-string v1, "Content-Type"
    const-string v2, "application/json"
    invoke-virtual {v0, v1, v2}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V
    if-eqz p3, :nob
    new-instance v2, Ljava/lang/StringBuilder;
    const-string v1, "Bearer "
    invoke-direct {v2, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v1, "Authorization"
    invoke-virtual {v0, v1, v2}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V
    :nob
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getOutputStream()Ljava/io/OutputStream;
    move-result-object v1
    const-string v2, "UTF-8"
    invoke-virtual {p1, v2}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/io/OutputStream;->write([B)V
    invoke-virtual {v1}, Ljava/io/OutputStream;->close()V
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getResponseCode()I
    move-result v1
    sput v1, Lcom/turntable/player/TalkPoll;->code:I
    const/16 v2, 0x12c
    if-lt v1, v2, :ok
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V
    const/4 v1, 0x0
    return-object v1
    :ok
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;
    move-result-object v1
    new-instance v2, Ljava/io/ByteArrayOutputStream;
    invoke-direct {v2}, Ljava/io/ByteArrayOutputStream;-><init>()V
    const/16 v3, 0x1000
    new-array v3, v3, [B
    :loop
    invoke-virtual {v1, v3}, Ljava/io/InputStream;->read([B)I
    move-result v4
    if-lez v4, :end
    const/4 v5, 0x0
    invoke-virtual {v2, v3, v5, v4}, Ljava/io/ByteArrayOutputStream;->write([BII)V
    goto :loop
    :end
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V
    const-string v1, "UTF-8"
    invoke-virtual {v2, v1}, Ljava/io/ByteArrayOutputStream;->toString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    return-object v1
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :e
    :e
    const/4 v0, 0x0
    return-object v0
.end method

# 로그인 토큰: 만료 2분 전이면 새로 받는다. 실패 시 null(네트워크) 또는 "!"(로그인 만료)
.method private token(Landroid/content/SharedPreferences;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .locals 8
    const-string v0, "at"
    const-string v1, ""
    invoke-interface {p1, v0, v1}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    const-string v0, "exp"
    const-wide/16 v3, 0x0
    invoke-interface {p1, v0, v3, v4}, Landroid/content/SharedPreferences;->getLong(Ljava/lang/String;J)J
    move-result-wide v3
    const-wide/16 v5, 0x3e8
    mul-long/2addr v3, v5
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v5
    sub-long/2addr v3, v5
    const-wide/32 v5, 0x1d4c0
    cmp-long v0, v3, v5
    if-ltz v0, :refresh
    return-object v2
    :refresh
    const-string v0, "rt"
    invoke-interface {p1, v0, v1}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    const-string v4, "/auth/v1/token?grant_type=refresh_token"
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    new-instance v0, Ljava/lang/StringBuilder;
    const-string v5, "{\"refresh_token\":\""
    invoke-direct {v0, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v5, "\"}"
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5
    const/4 v6, 0x0
    invoke-static {v4, v5, p3, v6}, Lcom/turntable/player/TalkPoll;->http(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    if-nez v0, :parse
    sget v1, Lcom/turntable/player/TalkPoll;->code:I
    const/16 v2, 0x190
    if-lt v1, v2, :neterr
    const/16 v2, 0x1f4
    if-ge v1, v2, :neterr
    const-string v0, "!"
    return-object v0
    :neterr
    const/4 v0, 0x0
    return-object v0
    :parse
    new-instance v1, Lorg/json/JSONObject;
    invoke-direct {v1, v0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    const-string v0, "access_token"
    invoke-virtual {v1, v0}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    const-string v0, "refresh_token"
    invoke-virtual {v1, v0}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    const-string v0, "expires_at"
    const-wide/16 v4, 0x0
    invoke-virtual {v1, v0, v4, v5}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J
    move-result-wide v4
    invoke-interface {p1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v0
    const-string v6, "at"
    invoke-interface {v0, v6, v2}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    const-string v6, "rt"
    invoke-interface {v0, v6, v3}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    const-string v6, "exp"
    invoke-interface {v0, v6, v4, v5}, Landroid/content/SharedPreferences$Editor;->putLong(Ljava/lang/String;J)Landroid/content/SharedPreferences$Editor;
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V
    return-object v2
.end method

# 대화방 목록에서 새 메시지를 찾아 알림. 새 메시지가 있었으면 true
.method private scan(Landroid/content/SharedPreferences;Ljava/lang/String;)Z
    .locals 14
    const-string v0, "me"
    const-string v1, ""
    invoke-interface {p1, v0, v1}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lcom/turntable/player/TalkPoll;->me:Ljava/lang/String;
    move-object/from16 v1, p2
    new-instance v0, Lorg/json/JSONArray;
    invoke-direct {v0, v1}, Lorg/json/JSONArray;-><init>(Ljava/lang/String;)V
    const-string v1, "map"
    const-string v2, "{}"
    invoke-interface {p1, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    new-instance v2, Lorg/json/JSONObject;
    invoke-direct {v2, v1}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    invoke-virtual {v2}, Lorg/json/JSONObject;->length()I
    move-result v3
    if-nez v3, :notfirst
    const/4 v3, 0x1
    goto :fset
    :notfirst
    const/4 v3, 0x0
    :fset
    const-string v1, "fg"
    const/4 v4, 0x0
    invoke-interface {p1, v1, v4}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v4
    const/4 v5, 0x0
    const/4 v6, 0x0
    invoke-virtual {v0}, Lorg/json/JSONArray;->length()I
    move-result v7
    :loop
    if-ge v6, v7, :fin
    invoke-virtual {v0, v6}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;
    move-result-object v8
    const-string v1, "id"
    invoke-virtual {v8, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v9
    const-string v1, "last_id"
    const-wide/16 v10, 0x0
    invoke-virtual {v8, v1, v10, v11}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J
    move-result-wide v10
    const-wide/16 v12, 0x0
    invoke-virtual {v2, v9, v12, v13}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J
    move-result-wide v12
    cmp-long v1, v10, v12
    if-lez v1, :next
    invoke-virtual {v2, v9, v10, v11}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;
    if-nez v3, :next
    if-nez v4, :next
    const-string v1, "last_sender"
    const-string v10, ""
    invoke-virtual {v8, v1, v10}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    iget-object v12, p0, Lcom/turntable/player/TalkPoll;->me:Ljava/lang/String;
    invoke-virtual {v1, v12}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :next
    const-string v1, "kind"
    invoke-virtual {v8, v1, v10}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v11, "all"
    invoke-virtual {v11, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :dm
    const-string v11, "전체 채팅"
    goto :body
    :dm
    const-string v1, "peer_nick"
    const-string v11, "해피톡"
    invoke-virtual {v8, v1, v11}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v11
    :body
    const-string v1, "last_body"
    invoke-virtual {v8, v1}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z
    move-result v12
    if-nez v12, :nobody
    invoke-virtual {v8, v1, v10}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v12
    goto :show
    :nobody
    const-string v1, "last_file"
    invoke-virtual {v8, v1}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z
    move-result v12
    if-nez v12, :plain
    new-instance v12, Ljava/lang/StringBuilder;
    const-string v13, "📎 "
    invoke-direct {v12, v13}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v8, v1, v10}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v13
    invoke-virtual {v12, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v12}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v12
    goto :show
    :plain
    const-string v12, "새 메시지"
    :show
    iget-object v1, p0, Lcom/turntable/player/TalkPoll;->svc:Lcom/turntable/player/TalkService;
    invoke-static {v1, v11, v12, v9}, Lcom/turntable/player/TalkNotify;->show(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const/4 v5, 0x1
    :next
    add-int/lit8 v6, v6, 0x1
    goto :loop
    :fin
    invoke-interface {p1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v0
    const-string v1, "map"
    invoke-virtual {v2}, Lorg/json/JSONObject;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    if-eqz v5, :ap
    const-string v1, "last"
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v6
    invoke-interface {v0, v1, v6, v7}, Landroid/content/SharedPreferences$Editor;->putLong(Ljava/lang/String;J)Landroid/content/SharedPreferences$Editor;
    :ap
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V
    return v5
.end method

.method public run()V
    .locals 8
    const-wide/32 v4, 0x1d4c0
    const/4 v6, 0x0
    :try_start
    iget-object v0, p0, Lcom/turntable/player/TalkPoll;->svc:Lcom/turntable/player/TalkService;
    const-string v1, "talk"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Lcom/turntable/player/TalkService;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v0
    const-string v1, "on"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v1
    if-nez v1, :on
    iget-object v1, p0, Lcom/turntable/player/TalkPoll;->svc:Lcom/turntable/player/TalkService;
    invoke-virtual {v1}, Lcom/turntable/player/TalkService;->stopSelf()V
    goto :stop
    :on
    const-string v1, "fg"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v1
    if-eqz v1, :bg
    const-wide/32 v4, 0x2bf20
    goto :done
    :bg
    iget-object v1, p0, Lcom/turntable/player/TalkPoll;->svc:Lcom/turntable/player/TalkService;
    const-string v2, "connectivity"
    invoke-virtual {v1, v2}, Lcom/turntable/player/TalkService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/net/ConnectivityManager;
    invoke-virtual {v1}, Landroid/net/ConnectivityManager;->getActiveNetwork()Landroid/net/Network;
    move-result-object v1
    if-nez v1, :net
    const-wide/32 v4, 0x2bf20
    goto :done
    :net
    iget-object v1, p0, Lcom/turntable/player/TalkPoll;->svc:Lcom/turntable/player/TalkService;
    const-string v2, "power"
    invoke-virtual {v1, v2}, Lcom/turntable/player/TalkService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/os/PowerManager;
    const/4 v2, 0x1
    const-string v3, "happymusic:talk"
    invoke-virtual {v1, v2, v3}, Landroid/os/PowerManager;->newWakeLock(ILjava/lang/String;)Landroid/os/PowerManager$WakeLock;
    move-result-object v6
    const-wide/16 v1, 0x7530
    invoke-virtual {v6, v1, v2}, Landroid/os/PowerManager$WakeLock;->acquire(J)V
    const-string v1, "url"
    const-string v2, ""
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    const-string v1, "key"
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v7
    invoke-direct {p0, v0, v3, v7}, Lcom/turntable/player/TalkPoll;->token(Landroid/content/SharedPreferences;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :done
    const-string v2, "!"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :tok
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v1
    const-string v2, "on"
    const/4 v3, 0x0
    invoke-interface {v1, v2, v3}, Landroid/content/SharedPreferences$Editor;->putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;
    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->apply()V
    iget-object v1, p0, Lcom/turntable/player/TalkPoll;->svc:Lcom/turntable/player/TalkService;
    invoke-virtual {v1}, Lcom/turntable/player/TalkService;->stopSelf()V
    goto :stop
    :tok
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    const-string v3, "/rest/v1/rpc/hm_rooms"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "{}"
    invoke-static {v2, v3, v7, v1}, Lcom/turntable/player/TalkPoll;->http(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    if-nez v1, :got
    sget v2, Lcom/turntable/player/TalkPoll;->code:I
    const/16 v3, 0x191
    if-ne v2, v3, :done
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v2
    const-string v3, "exp"
    const-wide/16 v4, 0x0
    invoke-interface {v2, v3, v4, v5}, Landroid/content/SharedPreferences$Editor;->putLong(Ljava/lang/String;J)Landroid/content/SharedPreferences$Editor;
    invoke-interface {v2}, Landroid/content/SharedPreferences$Editor;->apply()V
    const-wide/16 v4, 0x1388
    goto :done
    :got
    invoke-direct {p0, v0, v1}, Lcom/turntable/player/TalkPoll;->scan(Landroid/content/SharedPreferences;Ljava/lang/String;)Z
    const-string v1, "last"
    const-wide/16 v2, 0x0
    invoke-interface {v0, v1, v2, v3}, Landroid/content/SharedPreferences;->getLong(Ljava/lang/String;J)J
    move-result-wide v2
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v4
    sub-long/2addr v4, v2
    const-wide/32 v2, 0x927c0
    cmp-long v1, v4, v2
    if-gez v1, :slow1
    const-wide/16 v4, 0x7530
    goto :done
    :slow1
    const-wide/32 v2, 0x36ee80
    cmp-long v1, v4, v2
    if-gez v1, :slow2
    const-wide/32 v4, 0x15f90
    goto :done
    :slow2
    const-wide/32 v4, 0x493e0
    :done
    nop
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :err
    goto :sched
    :err
    const-wide/32 v4, 0x1d4c0
    :sched
    if-eqz v6, :nowl
    invoke-virtual {v6}, Landroid/os/PowerManager$WakeLock;->isHeld()Z
    move-result v0
    if-eqz v0, :nowl
    invoke-virtual {v6}, Landroid/os/PowerManager$WakeLock;->release()V
    :nowl
    sget-object v0, Lcom/turntable/player/TalkService;->inst:Lcom/turntable/player/TalkService;
    if-eqz v0, :ret
    invoke-virtual {v0, v4, v5}, Lcom/turntable/player/TalkService;->schedule(J)V
    :ret
    return-void
    :stop
    if-eqz v6, :ret
    invoke-virtual {v6}, Landroid/os/PowerManager$WakeLock;->isHeld()Z
    move-result v0
    if-eqz v0, :ret
    invoke-virtual {v6}, Landroid/os/PowerManager$WakeLock;->release()V
    return-void
.end method
