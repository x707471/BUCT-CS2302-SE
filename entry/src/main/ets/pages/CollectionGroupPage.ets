import { router } from '@kit.ArkUI'
import { httpGetRaw, httpPostRaw } from '../common/utils/HttpUtil'
import { API, BASE_URL } from '../common/constants/ApiConstants'
import { CommonConstants } from '../common/constants/CommonConstants'
import { CollectionGroup, Artifact, ArtifactRouteParams } from '../mode/type'
import { UserService } from '../common/utils/UserService'

@Entry
@Component
struct CollectionGroupPage {
  @State groups: CollectionGroup[] = []
  @State isLoading: boolean = true
  @State selectedGroup: string = ''
  @State groupArtifacts: Artifact[] = []
  @State showArtifacts: boolean = false

  async aboutToAppear() {
    await this.loadGroups()
  }

  async loadGroups() {
    this.isLoading = true
    const userService = UserService.getInstance()
    if (!userService.isLoggedIn) {
      this.isLoading = false
      return
    }
    try {
      this.groups = await httpGetRaw<CollectionGroup[]>(API.COLLECTION_GROUPS(userService.userId))
    } catch (e) {
      this.groups = []
    }
    this.isLoading = false
  }

  async loadGroupArtifacts(groupName: string) {
    this.selectedGroup = groupName
    this.showArtifacts = true
    const userService = UserService.getInstance()
    try {
      this.groupArtifacts = await httpGetRaw<Artifact[]>(
        `${BASE_URL}/api/collection/group-detail?userId=${userService.userId}&groupName=${encodeURIComponent(groupName)}`
      )
    } catch (e) {
      this.groupArtifacts = []
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => {
            if (this.showArtifacts) {
              this.showArtifacts = false
            } else {
              router.back()
            }
          })

        Text(this.showArtifacts ? this.selectedGroup : '收藏分组')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')

      if (this.showArtifacts) {
        this.GroupArtifactsView()
      } else {
        this.GroupListView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  GroupListView() {
    if (this.isLoading) {
      Column() {
        LoadingProgress().width(40).height(40).color('#C62828')
        Text('加载中...').fontSize(14).fontColor('#999999').margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.groups.length === 0) {
      Column() {
        Text('⭐').fontSize(48)
        Text('暂无收藏分组').fontSize(16).fontColor('#999999').margin({ top: 16 })
        Text('在文物详情页收藏后自动创建分组').fontSize(12).fontColor('#CCCCCC').margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.groups, (group: CollectionGroup) => {
          ListItem() {
            Row() {
              Column() {
                Text(group.groupName || '默认分组')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                Text(`${group.count} 件文物`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('>')
                .fontSize(18)
                .fontColor('#CCCCCC')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .onClick(() => { this.loadGroupArtifacts(group.groupName) })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12 })
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  GroupArtifactsView() {
    if (this.groupArtifacts.length === 0) {
      Column() {
        Text('该分组暂无文物').fontSize(14).fontColor('#999999')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.groupArtifacts, (item: Artifact) => {
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
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
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
      .padding({ left: 16, right: 16, top: 12 })
      .scrollBar(BarState.Off)
    }
  }
}
