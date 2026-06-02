import { router } from '@kit.ArkUI'
import { httpPostRaw } from '../common/utils/HttpUtil'
import { API } from '../common/constants/ApiConstants'
import { UserService } from '../common/utils/UserService'
import { LoginResponse, LoginRequest, RegisterRequest } from '../mode/type'

@Entry
@Component
struct LoginPage {
  @State isLogin: boolean = true
  @State username: string = ''
  @State password: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State isLoading: boolean = false
  @State errorMsg: string = ''

  build() {
    Column() {
      Column() {
        Image($r('app.media.startIcon'))
          .width(80)
          .height(80)
          .margin({ top: 60 })
        Text('博物馆导览')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#C62828')
          .margin({ top: 16 })
        Text('探索中华文明瑰宝')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Column() {
        Row() {
          Text('登录')
            .fontSize(18)
            .fontWeight(this.isLogin ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.isLogin ? '#C62828' : '#999999')
            .padding({ bottom: 8 })
            .borderWidth({ bottom: this.isLogin ? 2 : 0 })
            .borderColor('#C62828')
            .onClick(() => { this.isLogin = true; this.errorMsg = '' })

          Blank().width(40)

          Text('注册')
            .fontSize(18)
            .fontWeight(!this.isLogin ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(!this.isLogin ? '#C62828' : '#999999')
            .padding({ bottom: 8 })
            .borderWidth({ bottom: !this.isLogin ? 2 : 0 })
            .borderColor('#C62828')
            .onClick(() => { this.isLogin = false; this.errorMsg = '' })
        }
        .margin({ top: 32, bottom: 20 })

        TextInput({ placeholder: '请输入用户名' })
          .width('100%')
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .onChange((value: string) => { this.username = value; this.errorMsg = '' })
          .margin({ bottom: 12 })

        if (!this.isLogin) {
          TextInput({ placeholder: '请输入邮箱' })
            .width('100%')
            .height(48)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
            .type(InputType.Email)
            .onChange((value: string) => { this.email = value; this.errorMsg = '' })
            .margin({ bottom: 12 })

          TextInput({ placeholder: '请输入手机号' })
            .width('100%')
            .height(48)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
            .type(InputType.PhoneNumber)
            .onChange((value: string) => { this.phone = value; this.errorMsg = '' })
            .margin({ bottom: 12 })
        }

        TextInput({ placeholder: '请输入密码' })
          .width('100%')
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .type(InputType.Password)
          .onChange((value: string) => { this.password = value; this.errorMsg = '' })
          .margin({ bottom: 8 })

        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(12)
            .fontColor('#FF0000')
            .width('100%')
            .margin({ bottom: 8 })
        }

        Button(this.isLogin ? '登 录' : '注 册')
          .width('100%')
          .height(48)
          .backgroundColor('#C62828')
          .borderRadius(24)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .margin({ top: 16 })
          .enabled(!this.isLoading)
          .onClick(() => { this.handleSubmit() })

        if (this.isLogin) {
          Text('请先注册账号后登录')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  async handleSubmit() {
    if (!this.username || !this.password) {
      this.errorMsg = '请填写用户名和密码'
      return
    }
    if (!this.isLogin && !this.email && !this.phone) {
      this.errorMsg = '请填写邮箱或手机号'
      return
    }
    this.isLoading = true
    try {
      if (this.isLogin) {
        const loginBody: LoginRequest = { username: this.username, password: this.password }
        const result: LoginResponse = await httpPostRaw<LoginResponse>(
          API.USER_LOGIN,
          loginBody
        )
        if (result.code === 200 && result.data) {
          const userService = UserService.getInstance()
          await userService.login(result.data.id, result.data.username)
          router.replaceUrl({ url: 'pages/MainPage' })
        } else {
          this.errorMsg = result.message || '登录失败'
        }
      } else {
        const registerBody: RegisterRequest = {
          username: this.username,
          password: this.password,
          email: this.email,
          phone: this.phone,
        }
        const result: LoginResponse = await httpPostRaw<LoginResponse>(
          API.USER_REGISTER,
          registerBody
        )
        if (result.code === 200) {
          this.isLogin = true
          this.errorMsg = ''
        } else {
          this.errorMsg = result.message || '注册失败'
        }
      }
    } catch (e) {
      const errMsg = (e as Error).message
      this.errorMsg = errMsg || '网络错误，请检查后端服务'
    }
    this.isLoading = false
  }
}
