import { router } from '@kit.ArkUI'
import { httpGetRaw, httpUpload } from '../common/utils/HttpUtil'
import { API } from '../common/constants/ApiConstants'
import { CommonConstants } from '../common/constants/CommonConstants'
import { UserService } from '../common/utils/UserService'
import { UserUpload } from '../mode/type'
import { picker } from '@kit.CoreFileKit'
import { getContext } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'

@Entry
@Component
struct UserUploadPage {
  @State uploads: UserUpload[] = []
  @State isLoading: boolean = true
  @State description: string = ''
  @State selectedImagePath: string = ''
  @State isUploading: boolean = false
  @State artifactId: number = 0

  async aboutToAppear() {
    const params = router.getParams() as Record<string, number>
    if (params && params['artifactId']) {
      this.artifactId = params['artifactId']
    }
    await this.loadUploads()
  }

  async loadUploads() {
    this.isLoading = true
    const userService = UserService.getInstance()
    if (!userService.isLoggedIn) {
      this.isLoading = false
      return
    }
    try {
      this.uploads = await httpGetRaw<UserUpload[]>(API.USER_UPLOADS(userService.userId))
    } catch (e) {
      this.uploads = []
    }
    this.isLoading = false
  }

  async selectImage() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      const photoViewPicker = new picker.PhotoViewPicker()
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions)
      if (photoSelectResult.photoUris.length > 0) {
        this.selectedImagePath = photoSelectResult.photoUris[0]
      }
    } catch (e) {
    }
  }

  async copyToCache(srcPath: string): Promise<string> {
    const context = getContext(this)
    const cacheDir = context.cacheDir
    const ext = srcPath.split('.').pop()?.toLowerCase() || 'jpg'
    const fileName = `upload_${Date.now()}.${ext}`
    const destPath = `${cacheDir}/${fileName}`
    const srcFile = fileIo.openSync(srcPath, fileIo.OpenMode.READ_ONLY)
    const destFile = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
    const stat = fileIo.statSync(srcPath)
    const buf = new ArrayBuffer(stat.size)
    fileIo.readSync(srcFile.fd, buf)
    fileIo.writeSync(destFile.fd, buf)
    fileIo.closeSync(srcFile)
    fileIo.closeSync(destFile)
    return `internal://cache/${fileName}`
  }

  async submitUpload() {
    if (!this.selectedImagePath) {
      return
    }
    this.isUploading = true
    const userService = UserService.getInstance()
    try {
      const uploadPath = await this.copyToCache(this.selectedImagePath)
      const context = getContext(this)
      const formData: Record<string, string> = {
        'userId': String(userService.userId),
        'artifactId': String(this.artifactId),
        'mediaType': 'image',
        'caption': this.description,
      }
      await httpUpload<object>(API.UPLOAD_ADD, uploadPath, context, formData)
      this.selectedImagePath = ''
      this.description = ''
      await this.loadUploads()
    } catch (e) {
    }
    this.isUploading = false
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => { router.back() })

        Text('我的上传')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          Column() {
            Text('上传文物照片')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 12 })

            if (this.selectedImagePath) {
              Image(this.selectedImagePath)
                .width('100%')
                .height(200)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .margin({ bottom: 12 })
            } else {
              Column() {
                Text('📷').fontSize(40)
                Text('点击选择照片')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(160)
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 12 })
              .border({ width: 1, color: '#E0E0E0', style: BorderStyle.Dashed })
              .onClick(() => { this.selectImage() })
            }

            TextInput({ placeholder: '添加简短说明（选填）' })
              .width('100%')
              .height(44)
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .onChange((value: string) => { this.description = value })

            Text('上传内容需经后台审核后公开展示')
              .fontSize(12)
              .fontColor('#FF9800')
              .margin({ top: 8 })

            Button('上传照片')
              .width('100%')
              .height(44)
              .backgroundColor('#C62828')
              .fontColor('#FFFFFF')
              .borderRadius(22)
              .margin({ top: 16 })
              .enabled(!this.isUploading && this.selectedImagePath !== '')
              .onClick(() => { this.submitUpload() })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          Text('上传记录')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .margin({ top: 16, bottom: 8 })

          if (this.uploads.length === 0) {
            Column() {
              Text('暂无上传记录').fontSize(14).fontColor('#999999')
            }
            .width('100%')
            .padding({ top: 24, bottom: 24 })
            .justifyContent(FlexAlign.Center)
          } else {
            ForEach(this.uploads, (upload: UserUpload) => {
              Column() {
                Row() {
                  if (upload.imagePath) {
                    Image(CommonConstants.resolveImageUrl(upload.imagePath))
                      .width(60)
                      .height(60)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                  }
                  Column() {
                    Text(upload.description || '无说明')
                      .fontSize(14)
                      .fontColor('#333333')
                      .maxLines(2)
                    Text(upload.createdAt || '')
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 4 })
                    Row() {
                      Text(upload.status === 'approved' ? '已通过' : upload.status === 'rejected' ? '未通过' : '审核中')
                        .fontSize(12)
                        .fontColor(upload.status === 'approved' ? '#2E7D32' : upload.status === 'rejected' ? '#C62828' : '#FF9800')
                        .backgroundColor(upload.status === 'approved' ? '#E8F5E9' : upload.status === 'rejected' ? '#FFEBEE' : '#FFF3E0')
                        .borderRadius(4)
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    }
                    .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: 12 })
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .margin({ bottom: 8 })
            })
          }
        }
        .padding({ left: 16, right: 16, top: 12 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
