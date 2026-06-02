import { router } from '@kit.ArkUI'
import { httpGetRaw, httpPostRaw } from '../common/utils/HttpUtil'
import { API } from '../common/constants/ApiConstants'
import { CommonConstants } from '../common/constants/CommonConstants'
import { BrowseHistoryItem, UserIdRequest, ArtifactRouteParams } from '../mode/type'
import { UserService } from '../common/utils/UserService'

@Entry
@Component
struct BrowseHistoryPage {
  @State historyList: BrowseHistoryItem[] = []
  @State isLoading: boolean = true

  async aboutToAppear() {
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
      this.historyList = await httpGetRaw<BrowseHistoryItem[]>(
        `${API.BROWSE_HISTORY}?userId=${userService.userId}`
      )
    } catch (e) {
      this.historyList = []
    }
    this.isLoading = false
  }

  async clearHistory() {
    const userService = UserService.getInstance()
    if (!userService.isLoggedIn) {
      return
    }
    try {
      const body: UserIdRequest = { userId: userService.userId }
      await httpPostRaw<object>(`${API.BROWSE_HISTORY_CLEAR}?userId=${userService.userId}`, body)
      this.historyList = []
    } catch (e) {
    }
  }

  async deleteItem(id: number) {
    const userService = UserService.getInstance()
    if (!userService.isLoggedIn) {
      return
    }
    try {
      const body: UserIdRequest = { userId: userService.userId }
      await httpPostRaw<object>(`${API.BROWSE_HISTORY_DELETE(id)}?userId=${userService.userId}`, body)
      this.historyList = this.historyList.filter((h: BrowseHistoryItem) => h.id !== id)
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

        Text('浏览历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })
          .layoutWeight(1)

        if (this.historyList.length > 0) {
          Text('清空')
            .fontSize(14)
            .fontColor('#C62828')
            .onClick(() => this.clearHistory())
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#C62828')
          Text('加载中...').fontSize(14).fontColor('#999999').margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.historyList.length === 0) {
        Column() {
          Text('🕐').fontSize(48)
          Text('暂无浏览历史').fontSize(16).fontColor('#999999').margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.historyList, (item: BrowseHistoryItem) => {
            ListItem() {
              Row() {
                if (item.artifact?.imageUrl) {
                  Image(CommonConstants.resolveImageUrl(item.artifact.imageUrl))
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
                  Text(item.artifact?.titleZh || '未知文物')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .maxLines(1)
                  Text(item.browseTime || '')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 })

                Text('✕')
                  .fontSize(16)
                  .fontColor('#CCCCCC')
                  .padding(8)
                  .onClick(() => this.deleteItem(item.id))
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .onClick(() => {
                if (item.artifactId) {
                  const routeParams: ArtifactRouteParams = { artifactId: item.artifactId }
                  router.pushUrl({ url: 'pages/ArtifactDetailPage', params: routeParams })
                }
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
