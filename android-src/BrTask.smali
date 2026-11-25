.class public Lcom/turntable/player/BrTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field final op:I
.field final s:Ljava/lang/String;
.field final a:I
.field final b:I

.method public constructor <init>(ILjava/lang/String;II)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput p1, p0, Lcom/turntable/player/BrTask;->op:I
    iput-object p2, p0, Lcom/turntable/player/BrTask;->s:Ljava/lang/String;
    iput p3, p0, Lcom/turntable/player/BrTask;->a:I
    iput p4, p0, Lcom/turntable/player/BrTask;->b:I
    return-void
.end method

.method public run()V
    .locals 5
    iget v0, p0, Lcom/turntable/player/BrTask;->op:I
    iget-object v1, p0, Lcom/turntable/player/BrTask;->s:Ljava/lang/String;
    iget v2, p0, Lcom/turntable/player/BrTask;->a:I
    iget v3, p0, Lcom/turntable/player/BrTask;->b:I
    :try_start
    if-nez v0, :n1
    invoke-static {v1, v2, v3}, Lcom/turntable/player/Br;->open(Ljava/lang/String;II)V
    goto :end
    :n1
    const/4 v4, 0x1
    if-ne v0, v4, :n8
    invoke-static {v1}, Lcom/turntable/player/Br;->load(Ljava/lang/String;)V
    goto :end
    :n8
    const/16 v4, 0x8
    if-ne v0, v4, :other
    invoke-static {v2, v3}, Lcom/turntable/player/Br;->bounds(II)V
    goto :end
    :other
    invoke-static {v0}, Lcom/turntable/player/Br;->cmd(I)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :end
    :end
    return-void
.end method
