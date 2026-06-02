import { router } from '@kit.ArkUI'
import { httpGetRaw, httpPostRaw } from '../common/utils/HttpUtil'
import { API } from '../common/constants/ApiConstants'
import { CommonConstants } from '../common/constants/CommonConstants'
import { Artifact, UserArtifactRequest, ArtifactRouteParams, TabRouteParams } from '../mode/type'
import { UserService } from '../common/utils/UserService'

@Entry
@Component
struct MyCollectionsPage {
  @State artifacts: Artifact[] = []
  @State currentTab: string = 'collections'
  @State isLoading: boolean = true

  async aboutToAppear() {
    const params = router.getParams() as TabRouteParams
    if (params && params.tab) {
      this.currentTab = params.tab
    }
    await this.loadData()
  }

  async loadData() {
    this.isLoading = true
    const userService = UserService.getInstance()
    if (!userService.isLoggedIn) {
      this.isLoading = false
      return
    }
    try {
      if (this.currentTab === 'likes') {
        this.artifacts = await httpGetRaw<Artifact[]>(`${API.LIKES}?userId=${userService.userId}`)
      } else {
        this.artifacts = await httpGetRaw<Artifact[]>(`${API.COLLECTIONS}?userId=${userService.userId}`)
      }
    } catch (e) {
      this.artifacts = []
    }
    this.isLoading = false
  }

  async removeItem(artifactId: number) {
    const userService = UserService.getInstance()
    if (!userService.isLoggedIn) {
      return
    }
    try {
      const removeBody: UserArtifactRequest = { userId: userService.userId, artifactId: artifactId }
      if (this.currentTab === 'likes') {
        await httpPostRaw<object>(API.LIKE_REMOVE, removeBody)
      } else {
        await httpPostRaw<object>(API.COLLECTION_REMOVE, removeBody)
      }
      this.artifacts = this.artifacts.filter((a: Artifact) => a.id !== artifactId)
    } catch (e) {
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => { router.back() })

        Text(this.currentTab === 'likes' ? '我的点赞' : '我的收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')

      Row() {
        Text('收藏')
          .fontSize(16)
          .fontWeight(this.currentTab === 'collections' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === 'collections' ? '#C62828' : '#999999')
          .padding({ bottom: 8 })
          .borderWidth({ bottom: this.currentTab === 'collections' ? 2 : 0 })
          .borderColor('#C62828')
          .onClick(() => { this.currentTab = 'collections'; this.loadData() })

        Blank().width(32)

        Text('点赞')
          .fontSize(16)
          .fontWeight(this.currentTab === 'likes' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === 'likes' ? '#C62828' : '#999999')
          .padding({ bottom: 8 })
          .borderWidth({ bottom: this.currentTab === 'likes' ? 2 : 0 })
          .borderColor('#C62828')
          .onClick(() => { this.currentTab = 'likes'; this.loadData() })
      }
      .width('100%')
      .padding({ left: 16, top: 8 })
      .backgroundColor('#FFFFFF')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#C62828')
          Text('加载中...').fontSize(14).fontColor('#999999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.artifacts.length === 0) {
        Column() {
          Text(this.currentTab === 'likes' ? '👍' : '⭐')
            .fontSize(48)
          Text(this.currentTab === 'likes' ? '暂无点赞' : '暂无收藏')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.artifacts, (item: Artifact) => {
            ListItem() {
              Row() {
                if (item.imageUrl) {
                  Image(CommonConstants.resolveImageUrl(item.imageUrl))
                    .width(72)
                    .height(72)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                } else {
                  Column() {
                    Text('🏛️').fontSize(24)
                  }
                  .width(72)
                  .height(72)
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
                  Text(item.museumName || '')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 })

                Text('✕')
                  .fontSize(16)
                  .fontColor('#CCCCCC')
                  .padding(8)
                  .onClick(() => this.removeItem(item.id))
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
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
