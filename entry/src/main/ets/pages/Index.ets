import { UserService } from '../common/utils/UserService'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  async aboutToAppear() {
    const userService = UserService.getInstance()
    await userService.init(getContext(this))
    setTimeout(() => {
      if (userService.isLoggedIn) {
        router.replaceUrl({ url: 'pages/MainPage' })
      } else {
        router.replaceUrl({ url: 'pages/LoginPage' })
      }
    }, 500)
  }

  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(120)
        .height(120)
        .margin({ top: 200 })
      Text('博物馆导览')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 20 })
      Text('探索中华文明瑰宝')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 8 })
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#C62828')
        .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}
