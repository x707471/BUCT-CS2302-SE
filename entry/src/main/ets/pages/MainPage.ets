import { router } from '@kit.ArkUI'
import { httpGetRaw } from '../common/utils/HttpUtil'
import { UserService } from '../common/utils/UserService'
import { CommonConstants } from '../common/constants/CommonConstants'
import { API } from '../common/constants/ApiConstants'
import { Artifact, QuickActionItem, ArtifactRouteParams, FilterRouteParams, TabRouteParams } from '../mode/type'

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0
  @State username: string = ''
  @State hotArtifacts: Artifact[] = []
  @State isLoadingHot: boolean = true

  private tabsController: TabsController = new TabsController()

  private quickActions: QuickActionItem[] = [
    { icon: '🏛️', label: '文物', action: () => { router.pushUrl({ url: 'pages/ArtifactListPage' }) } },
    { icon: '🔍', label: '搜图', action: () => { router.pushUrl({ url: 'pages/ImageSearchPage' }) } },
    { icon: '🎤', label: '语音', action: () => { router.pushUrl({ url: 'pages/VoiceSearchPage' }) } },
    { icon: '💬', label: '问答', action: () => { router.pushUrl({ url: 'pages/VoiceQaPage' }) } },
  ]

  private swiperTexts: string[] = ['探索千年文明', '品鉴国宝重器', '传承文化精髓']

  async aboutToAppear() {
    const userService = UserService.getInstance()
    this.username = userService.username
    await this.loadHotArtifacts()
  }

  async loadHotArtifacts() {
    this.isLoadingHot = true
    try {
      this.hotArtifacts = await httpGetRaw<Artifact[]>(API.ARTIFACT_HOT)
    } catch (e) {
      try {
        this.hotArtifacts = await httpGetRaw<Artifact[]>(API.ARTIFACTS)
      } catch (e2) {
        this.hotArtifacts = []
      }
    }
    this.isLoadingHot = false
  }

  @Builder
  HomeTab() {
    Column() {
      Row() {
        Text('博物馆导览')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Blank()
        Image($r('app.media.startIcon'))
          .width(32)
          .height(32)
          .borderRadius(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Scroll() {
        Column() {
          Swiper() {
            ForEach(this.swiperTexts, (item: string) => {
              Column() {
                Text(item)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('国家博物馆导览系统')
                  .fontSize(14)
                  .fontColor('#FFFFFFCC')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(160)
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [['#C62828', 0.0], ['#D84315', 1.0]]
              })
            })
          }
          .autoPlay(true)
          .interval(3000)
          .indicator(true)
          .loop(true)
          .width('100%')
          .height(160)
          .margin({ left: 16, right: 16, top: 8 })

          Row() {
            ForEach(this.quickActions, (item: QuickActionItem) => {
              Column() {
                Text(item.icon)
                  .fontSize(28)
                Text(item.label)
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .width(70)
              .height(70)
              .borderRadius(12)
              .backgroundColor('#FFF5F5')
              .justifyContent(FlexAlign.Center)
              .onClick(() => item.action())
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
          .justifyContent(FlexAlign.SpaceBetween)

          Column() {
            Row() {
              Text('热门文物')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Blank()
              Text('查看更多 >')
                .fontSize(14)
                .fontColor('#C62828')
                .onClick(() => { router.pushUrl({ url: 'pages/ArtifactListPage' }) })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })

            this.HotArtifactsList()
          }
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  HotArtifactsList() {
    if (this.isLoadingHot) {
      Column() {
        LoadingProgress().width(40).height(40).color('#C62828')
        Text('加载中...').fontSize(14).fontColor('#999999').margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 32, bottom: 32 })
      .justifyContent(FlexAlign.Center)
    } else if (this.hotArtifacts.length === 0) {
      Column() {
        Text('暂无热门文物').fontSize(14).fontColor('#999999')
      }
      .width('100%')
      .padding({ top: 32, bottom: 32 })
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.hotArtifacts, (item: Artifact) => {
          ListItem() {
            Row() {
              if (item.imageUrl) {
                Image(CommonConstants.resolveImageUrl(item.imageUrl))
                  .width(80)
                  .height(80)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
              } else {
                Column() {
                  Text('🏛️').fontSize(28)
                }
                .width(80)
                .height(80)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .justifyContent(FlexAlign.Center)
              }
              Column() {
                Text(item.titleZh || item.titleEn)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .maxLines(1)
                Text(`${item.timePeriod || ''} · ${item.type || ''}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
                Text(item.museumName || `博物馆ID: ${item.museumId}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })

              Text('→')
                .fontSize(20)
                .fontColor('#CCCCCC')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              const routeParams: ArtifactRouteParams = { artifactId: item.id }
              router.pushUrl({ url: 'pages/ArtifactDetailPage', params: routeParams })
            })
          }
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  ExploreTab() {
    Column() {
      Text('分类浏览')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 8 })

      Scroll() {
        Column() {
          Text('按年代')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .padding({ left: 16, top: 8, bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(CommonConstants.ERA_LIST, (era: string) => {
              Text(era)
                .fontSize(14)
                .fontColor(era === '全部' ? '#FFFFFF' : '#666666')
                .backgroundColor(era === '全部' ? '#C62828' : '#F0F0F0')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ left: 8, bottom: 8 })
                .onClick(() => {
                  const filterParams: FilterRouteParams = { filter: 'era', value: era }
                  router.pushUrl({ url: 'pages/ArtifactListPage', params: filterParams })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 16 })

          Text('按类型')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .padding({ left: 16, top: 16, bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(CommonConstants.TYPE_LIST, (type: string) => {
              Text(type)
                .fontSize(14)
                .fontColor(type === '全部' ? '#FFFFFF' : '#666666')
                .backgroundColor(type === '全部' ? '#C62828' : '#F0F0F0')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ left: 8, bottom: 8 })
                .onClick(() => {
                  const filterParams: FilterRouteParams = { filter: 'type', value: type }
                  router.pushUrl({ url: 'pages/ArtifactListPage', params: filterParams })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 16 })

          Text('按博物馆')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .padding({ left: 16, top: 16, bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(CommonConstants.MUSEUM_LIST, (museum: string) => {
              Text(museum)
                .fontSize(14)
                .fontColor(museum === '全部' ? '#FFFFFF' : '#666666')
                .backgroundColor(museum === '全部' ? '#C62828' : '#F0F0F0')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ left: 8, bottom: 8 })
                .onClick(() => {
                  const filterParams: FilterRouteParams = { filter: 'museum', value: museum }
                  router.pushUrl({ url: 'pages/ArtifactListPage', params: filterParams })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 16, bottom: 16 })
        }
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  SearchTab() {
    Column() {
      Text('以图搜图')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 8 })

      Scroll() {
        Column() {
          Column() {
            Text('📷')
              .fontSize(64)
            Text('点击拍照或选择图片')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 16 })
            Text('上传文物图片，智能搜索相似藏品')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .margin({ top: 8 })
          }
          .width('100%')
          .height(240)
          .borderRadius(12)
          .backgroundColor('#FFFFFF')
          .justifyContent(FlexAlign.Center)
          .margin({ left: 16, right: 16, top: 16 })
          .border({ width: 2, color: '#E0E0E0', style: BorderStyle.Dashed })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ImageSearchPage' })
          })

          Column() {
            Text('语音搜索')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 12 })
            Row() {
              Column() {
                Text('🎤')
                  .fontSize(32)
                Text('语音搜文物')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .width('45%')
              .height(100)
              .borderRadius(12)
              .backgroundColor('#FFFFFF')
              .justifyContent(FlexAlign.Center)
              .onClick(() => { router.pushUrl({ url: 'pages/VoiceSearchPage' }) })

              Column() {
                Text('💬')
                  .fontSize(32)
                Text('智能问答')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .width('45%')
              .height(100)
              .borderRadius(12)
              .backgroundColor('#FFFFFF')
              .justifyContent(FlexAlign.Center)
              .onClick(() => { router.pushUrl({ url: 'pages/VoiceQaPage' }) })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 16, right: 16, top: 16 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  ProfileTab() {
    Column() {
      Row() {
        Column() {
          Text(this.username || '用户')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('欢迎来到博物馆导览')
            .fontSize(14)
            .fontColor('#FFFFFFCC')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 20, top: 40, bottom: 30 })
      .linearGradient({
        direction: GradientDirection.Right,
        colors: [['#C62828', 0.0], ['#D84315', 1.0]]
      })

      Column() {
        Row() {
          Text('❤️ 我的收藏')
            .fontSize(16)
            .fontColor('#333333')
          Blank()
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 12, topRight: 12 })
        .onClick(() => { router.pushUrl({ url: 'pages/CollectionGroupPage' }) })

        Divider().color('#F0F0F0')

        Row() {
          Text('👍 我的点赞')
            .fontSize(16)
            .fontColor('#333333')
          Blank()
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          const tabParams: TabRouteParams = { tab: 'likes' }
          router.pushUrl({ url: 'pages/MyCollectionsPage', params: tabParams })
        })

        Divider().color('#F0F0F0')

        Row() {
          Text('🕐 浏览历史')
            .fontSize(16)
            .fontColor('#333333')
          Blank()
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .onClick(() => { router.pushUrl({ url: 'pages/BrowseHistoryPage' }) })

        Divider().color('#F0F0F0')

        Row() {
          Text('📷 我的上传')
            .fontSize(16)
            .fontColor('#333333')
          Blank()
          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
        .onClick(() => { router.pushUrl({ url: 'pages/UserUploadPage' }) })
      }
      .margin({ left: 16, right: 16, top: -20 })

      Button('退出登录')
        .width('90%')
        .height(48)
        .backgroundColor('#FFFFFF')
        .fontColor('#C62828')
        .borderRadius(24)
        .border({ width: 1, color: '#C62828' })
        .margin({ top: 32 })
        .onClick(async () => {
          const userService = UserService.getInstance()
          await userService.logout()
          router.replaceUrl({ url: 'pages/LoginPage' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  build() {
    Column() {
      Tabs({ controller: this.tabsController }) {
        TabContent() {
          this.HomeTab()
        }.tabBar('首页')

        TabContent() {
          Column()
        }.tabBar('探索')

        TabContent() {
          this.SearchTab()
        }.tabBar('搜图')

        TabContent() {
          this.ProfileTab()
        }.tabBar('我的')
      }
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        if (index === 1) {
          this.tabsController.changeIndex(0)
          router.pushUrl({ url: 'pages/ArtifactListPage' })
        }
        this.currentIndex = index
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
