import { router } from '@kit.ArkUI'
import { httpGetRaw, httpPostRaw } from '../common/utils/HttpUtil'
import { UserService } from '../common/utils/UserService'
import { API, BASE_URL } from '../common/constants/ApiConstants'
import { CommonConstants } from '../common/constants/CommonConstants'
import { Artifact, Comment, ArtifactRouteParams, LikeCheckResult, CollectionCheckResult, UserArtifactRequest, CommentRequest } from '../mode/type'
import { AudioPlayerManager } from '../common/utils/AudioPlayerManager'

@Entry
@Component
struct ArtifactDetailPage {
  @State artifact: Artifact | null = null
  @State comments: Comment[] = []
  @State isLoading: boolean = true
  @State isLiked: boolean = false
  @State isCollected: boolean = false
  @State likesCount: number = 0
  @State commentText: string = ''
  @State imageScale: number = 1.0
  @State imageOffsetX: number = 0
  @State imageOffsetY: number = 0
  @State showFullImage: boolean = false
  @State currentMediaIndex: number = 0
  @State isPlaying: boolean = false
  @State playSpeed: number = 1.0
  @State currentMs: number = 0
  @State totalMs: number = 0
  @State audioUrl: string = ''

  private artifactId: number = 0
  private userService: UserService = UserService.getInstance()
  private playerManager: AudioPlayerManager = new AudioPlayerManager()

  clampOffset(containerHeight: number) {
    if (this.imageScale <= 1.0) {
      this.imageOffsetX = 0
      this.imageOffsetY = 0
      return
    }
    const maxOffsetX: number = 180 * (this.imageScale - 1)
    const maxOffsetY: number = (containerHeight / 2) * (this.imageScale - 1)
    this.imageOffsetX = Math.max(-maxOffsetX, Math.min(maxOffsetX, this.imageOffsetX))
    this.imageOffsetY = Math.max(-maxOffsetY, Math.min(maxOffsetY, this.imageOffsetY))
  }

  async aboutToAppear() {
    const params = router.getParams() as ArtifactRouteParams
    if (params && params.artifactId) {
      this.artifactId = params.artifactId
      await this.loadArtifactDetail()
      await this.loadComments()
      await this.checkLikeStatus()
      await this.checkCollectionStatus()
      await this.recordBrowseHistory()
      await this.initAudioPlayer()
    }
  }

  aboutToDisappear() {
    this.playerManager.stop()
    this.playerManager.release()
  }

  async initAudioPlayer() {
    await this.playerManager.initPlayer()

    this.playerManager.onProgressChange = (current: number, total: number) => {
      this.currentMs = current
      this.totalMs = total
    }

    this.playerManager.onStateChange = (state: string) => {
      if (state === 'playing') {
        this.isPlaying = true
      } else if (state === 'paused' || state === 'completed' || state === 'stopped') {
        this.isPlaying = false
      }
    }
  }

  async togglePlay() {
    if (this.isPlaying) {
      this.playerManager.pause()
    } else {
      if (!this.audioUrl) {
        try {
          const apiPath: string = API.ARTIFACT_AUDIO(this.artifactId)
          this.audioUrl = apiPath.startsWith('http') ? apiPath : `${BASE_URL}${apiPath}`
        } catch (err) {
          console.error('[AudioDebug] 路径生成失败: ' + JSON.stringify(err))
        }
      }
      if (this.audioUrl) {
        this.playerManager.playUrl(this.audioUrl)
      }
    }
  }

  changeSpeed(speed: number) {
    this.playSpeed = speed
    this.playerManager.setSpeed(speed)
  }

  formatTime(ms: number): string {
    const totalSeconds: number = Math.floor(ms / 1000)
    const minutes: number = Math.floor(totalSeconds / 60)
    const seconds: number = totalSeconds % 60
    return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`
  }

  async loadArtifactDetail() {
    this.isLoading = true
    try {
      this.artifact = await httpGetRaw<Artifact>(API.ARTIFACT_DETAIL(this.artifactId))
      this.likesCount = this.artifact?.likesCount || 0
    } catch (e) {
      this.artifact = null
    }
    this.isLoading = false
  }

  async loadComments() {
    try {
      const userId = this.userService.userId
      this.comments = await httpGetRaw<Comment[]>(`${API.COMMENTS}?artifactId=${this.artifactId}&userId=${userId}`)
    } catch (e) {
      this.comments = []
    }
  }

  async checkLikeStatus() {
    try {
      const userId = this.userService.userId
      const result = await httpGetRaw<LikeCheckResult>(`${API.LIKE_CHECK}?userId=${userId}&artifactId=${this.artifactId}`)
      this.isLiked = result.liked
    } catch (e) {
      this.isLiked = false
    }
  }

  async checkCollectionStatus() {
    try {
      const userId = this.userService.userId
      const result = await httpGetRaw<CollectionCheckResult>(`${API.COLLECTION_CHECK}?userId=${userId}&artifactId=${this.artifactId}`)
      this.isCollected = result.collected
    } catch (e) {
      this.isCollected = false
    }
  }

  async recordBrowseHistory() {
    try {
      const userId = this.userService.userId
      const body: UserArtifactRequest = { userId: userId, artifactId: this.artifactId }
      await httpPostRaw<object>(API.BROWSE_HISTORY_ADD, body)
    } catch (e) {}
  }

  async toggleLike() {
    const userId = this.userService.userId
    const body: UserArtifactRequest = { userId: userId, artifactId: this.artifactId }
    try {
      if (this.isLiked) {
        await httpPostRaw<object>(API.LIKE_REMOVE, body)
        this.isLiked = false
        this.likesCount = Math.max(0, this.likesCount - 1)
      } else {
        await httpPostRaw<object>(API.LIKE_ADD, body)
        this.isLiked = true
        this.likesCount++
      }
    } catch (e) {}
  }

  async toggleCollection() {
    const userId = this.userService.userId
    const body: UserArtifactRequest = { userId: userId, artifactId: this.artifactId }
    try {
      if (this.isCollected) {
        await httpPostRaw<object>(API.COLLECTION_REMOVE, body)
        this.isCollected = false
      } else {
        await httpPostRaw<object>(API.COLLECTION_ADD, body)
        this.isCollected = true
      }
    } catch (e) {}
  }

  async submitComment() {
    if (!this.commentText.trim()) return
    const userId = this.userService.userId
    const body: CommentRequest = {
      userId: userId,
      artifactId: this.artifactId,
      content: this.commentText,
    }
    try {
      await httpPostRaw<object>(API.COMMENTS, body)
      this.commentText = ''
      await this.loadComments()
    } catch (e) {}
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .onClick(() => { router.back() })

          Text('文物详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ left: 12 })
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#FFFFFF')

        if (this.isLoading) {
          Column() {
            LoadingProgress().width(48).height(48).color('#C62828')
            Text('加载中...').fontSize(14).fontColor('#999999').margin({ top: 12 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.artifact) {
          Scroll() {
            Column() {
              this.ImageSection()
              this.AttributeSection()
              this.AudioNarrationSection()
              this.DescriptionSection()
              this.CommentSection()
            }
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)

          this.BottomActionBar()
        } else {
          Column() {
            Text('加载失败').fontSize(16).fontColor('#999999')
            Button('重试')
              .margin({ top: 16 })
              .onClick(() => { this.loadArtifactDetail() })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F8F8')

      if (this.showFullImage) {
        this.FullImageViewer()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ImageSection() {
    Stack() {
      Image(CommonConstants.resolveImageUrl(this.artifact?.imageUrl || this.artifact?.detailUrl || ''))
        .width('100%')
        .height(280)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#F5F5F5')
        .scale({ x: this.imageScale, y: this.imageScale })
        .translate({ x: this.imageOffsetX, y: this.imageOffsetY })
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            PinchGesture({ fingers: 2 })
              .onActionUpdate((event: GestureEvent) => {
                this.imageScale = Math.max(1.0, Math.min(5.0, this.imageScale * event.scale))
              })
              .onActionEnd(() => {
                if (this.imageScale < 1.0) {
                  this.imageScale = 1.0
                }
                this.clampOffset(280)
              }),
            PanGesture()
              .onActionUpdate((event: GestureEvent) => {
                if (this.imageScale > 1.0) {
                  this.imageOffsetX += event.offsetX
                  this.imageOffsetY += event.offsetY
                  this.clampOffset(280)
                }
              })
              .onActionEnd(() => {
                this.clampOffset(280)
              }),
            TapGesture({ count: 2 })
              .onAction(() => {
                if (this.imageScale > 1.0) {
                  this.imageScale = 1.0
                  this.imageOffsetX = 0
                  this.imageOffsetY = 0
                } else {
                  this.imageScale = 2.5
                }
              })
          )
        )

      if (this.imageScale > 1.0) {
        Text('双击还原')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('#00000088')
          .borderRadius(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .position({ x: '50%', y: 8 })
          .translate({ x: '-50%' })
          .onClick(() => {
            this.imageScale = 1.0
            this.imageOffsetX = 0
            this.imageOffsetY = 0
          })
      }
    }
    .width('100%')
    .height(280)
    .alignContent(Alignment.Center)
  }

  @Builder
  FullImageViewer() {
    Stack() {
      Column() {
        Image(CommonConstants.resolveImageUrl(this.artifact?.imageUrl || this.artifact?.detailUrl || ''))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .backgroundColor('#000000')
          .scale({ x: this.imageScale, y: this.imageScale })
          .translate({ x: this.imageOffsetX, y: this.imageOffsetY })
          .gesture(
            GestureGroup(GestureMode.Exclusive,
              PinchGesture({ fingers: 2 })
                .onActionUpdate((event: GestureEvent) => {
                  this.imageScale = Math.max(1.0, Math.min(5.0, this.imageScale * event.scale))
                })
                .onActionEnd(() => {
                  if (this.imageScale < 1.0) {
                    this.imageScale = 1.0
                  }
                  this.clampOffset(800)
                }),
              PanGesture()
                .onActionUpdate((event: GestureEvent) => {
                  if (this.imageScale > 1.0) {
                    this.imageOffsetX += event.offsetX
                    this.imageOffsetY += event.offsetY
                    this.clampOffset(800)
                  }
                })
                .onActionEnd(() => {
                  this.clampOffset(800)
                }),
              TapGesture({ count: 2 })
                .onAction(() => {
                  if (this.imageScale > 1.0) {
                    this.imageScale = 1.0
                    this.imageOffsetX = 0
                    this.imageOffsetY = 0
                  } else {
                    this.imageScale = 2.5
                  }
                })
            )
          )
      }
      .width('100%')
      .height('100%')

      Row() {
        Text('✕')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .padding(12)
      }
      .position({ x: 16, y: 48 })
      .onClick(() => {
        this.showFullImage = false
        this.imageScale = 1.0
        this.imageOffsetX = 0
        this.imageOffsetY = 0
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000EE')
  }

  @Builder
  AttributeSection() {
    Column() {
      Text(this.artifact?.titleZh || this.artifact?.titleEn || '')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      if (this.artifact?.titleEn) {
        Text(this.artifact.titleEn)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
          .width('100%')
      }

      Row() {
        if (this.artifact?.timePeriod) {
          Text(this.artifact.timePeriod)
            .fontSize(12)
            .fontColor('#C62828')
            .backgroundColor('#FFF5F5')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        }
        if (this.artifact?.type) {
          Text(this.artifact.type)
            .fontSize(12)
            .fontColor('#1565C0')
            .backgroundColor('#E3F2FD')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ left: 8 })
        }
        if (this.artifact?.material) {
          Text(this.artifact.material)
            .fontSize(12)
            .fontColor('#2E7D32')
            .backgroundColor('#E8F5E9')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ left: 8 })
        }
      }
      .margin({ top: 12 })

      Column() {
        if (this.artifact?.museumName) {
          Row() {
            Text('所属博物馆：').fontSize(14).fontColor('#999999')
            Text(this.artifact.museumName).fontSize(14).fontColor('#333333')
          }
          .width('100%')
          .margin({ top: 8 })
        }
        if (this.artifact?.dimensions) {
          Row() {
            Text('尺寸：').fontSize(14).fontColor('#999999')
            Text(this.artifact.dimensions).fontSize(14).fontColor('#333333')
          }
          .width('100%')
          .margin({ top: 8 })
        }
        if (this.artifact?.objectId) {
          Row() {
            Text('藏品编号：').fontSize(14).fontColor('#999999')
            Text(this.artifact.objectId).fontSize(14).fontColor('#333333')
          }
          .width('100%')
          .margin({ top: 8 })
        }
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
    .margin({ top: -16 })
  }

  @Builder
  AudioNarrationSection() {
    Column() {
      Text('语音讲解')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        Button() {
          Text(this.isPlaying ? '⏸' : '▶')
            .fontSize(22)
            .fontColor('#FFFFFF')
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor(this.isPlaying ? '#FF6F00' : '#C62828')
        .onClick(() => { this.togglePlay() })

        Column() {
          Slider({
            value: this.currentMs,
            min: 0,
            max: Math.max(1, this.totalMs),
            step: 1,
            style: SliderStyle.InSet
          })
            .width('100%')
            .blockColor('#C62828')
            .blockSize({ width: 16, height: 16 })
            .trackColor('#E0E0E0')
            .selectedColor('#C62828')
            .trackThickness(4)
            .showSteps(false)
            .showTips(false)
            .onChange((value: number, mode: SliderChangeMode) => {
              if (mode === SliderChangeMode.Moving || mode === SliderChangeMode.Click) {
                this.playerManager.seek(value)
              }
            })

          Row() {
            Text(this.formatTime(this.currentMs))
              .fontSize(11)
              .fontColor('#999999')
            Text(this.formatTime(this.totalMs))
              .fontSize(11)
              .fontColor('#999999')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 2 })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')

      Row() {
        Text('倍速：')
          .fontSize(13)
          .fontColor('#666666')

        ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], (speed: number) => {
          Text(`${speed}x`)
            .fontSize(13)
            .fontColor(this.playSpeed === speed ? '#FFFFFF' : '#C62828')
            .backgroundColor(this.playSpeed === speed ? '#C62828' : '#FFF5F5')
            .borderRadius(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ left: 4 })
            .onClick(() => { this.changeSpeed(speed) })
        })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 16, right: 16 })
  }

  @Builder
  DescriptionSection() {
    Column() {
      Text('详细介绍')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 8 })

      Text(this.artifact?.description || '暂无介绍')
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 16, right: 16 })
  }

  @Builder
  CommentSection() {
    Column() {
      Row() {
        Text('评论')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Text(`(${this.comments.length})`)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.comments.length === 0) {
        Text('暂无评论，快来发表第一条评论吧')
          .fontSize(14)
          .fontColor('#CCCCCC')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 16, bottom: 16 })
      } else {
        ForEach(this.comments, (comment: Comment) => {
          Column() {
            Row() {
              Text(`用户${comment.userId}`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              if (comment.status === 'pending') {
                Text('待审核')
                  .fontSize(11)
                  .fontColor('#FF8F00')
                  .backgroundColor('#FFF8E1')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 8 })
              }
            }
            .width('100%')

            Text(comment.content)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 6 })
              .width('100%')

            Text(comment.createdAt || '')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .margin({ top: 4 })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })
          .borderRadius(8)
        })
      }

      Row() {
        TextInput({ placeholder: '写下你的评论...', text: this.commentText })
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F5F5F5')
          .onChange((value: string) => { this.commentText = value })

        Button('发送')
          .height(40)
          .backgroundColor('#C62828')
          .fontColor('#FFFFFF')
          .borderRadius(20)
          .margin({ left: 8 })
          .onClick(() => { this.submitComment() })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 16, right: 16, bottom: 16 })
  }

  @Builder
  BottomActionBar() {
    Row() {
      Column() {
        Text(this.isLiked ? '❤️' : '🤍')
          .fontSize(22)
        Text(`${this.likesCount}`)
          .fontSize(10)
          .fontColor('#999999')
      }
      .padding({ left: 16, right: 16 })
      .onClick(() => { this.toggleLike() })

      Column() {
        Text(this.isCollected ? '⭐' : '☆')
          .fontSize(22)
        Text('收藏')
          .fontSize(10)
          .fontColor('#999999')
      }
      .padding({ left: 16, right: 16 })
      .onClick(() => { this.toggleCollection() })

      Button('上传照片')
        .height(40)
        .backgroundColor('#FF6F00')
        .fontColor('#FFFFFF')
        .borderRadius(20)
        .layoutWeight(1)
        .margin({ left: 8, right: 8 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/UserUploadPage', params: { artifactId: this.artifactId } })
        })

      Button('语音问答')
        .height(40)
        .backgroundColor('#C62828')
        .fontColor('#FFFFFF')
        .borderRadius(20)
        .layoutWeight(1)
        .margin({ right: 16 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/VoiceQaPage', params: { artifactId: this.artifactId } })
        })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .border({ width: 0.5, color: '#E0E0E0' })
  }
}