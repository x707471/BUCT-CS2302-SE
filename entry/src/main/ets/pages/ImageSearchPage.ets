import { router } from '@kit.ArkUI'
import { httpUpload, ApiResponse } from '../common/utils/HttpUtil'
import { API } from '../common/constants/ApiConstants'
import { CommonConstants } from '../common/constants/CommonConstants'
import { Artifact, ArtifactRouteParams } from '../mode/type'
import { picker, fileIo as fs } from '@kit.CoreFileKit'
import { cameraPicker, camera } from '@kit.CameraKit'

@Entry
@Component
struct ImageSearchPage {
  @State selectedImagePath: string = ''
  @State isSearching: boolean = false
  @State searchResults: Artifact[] = []
  @State hasSearched: boolean = false

  private searchSteps: string[] = [
    '1. 拍摄或选择一张文物图片',
    '2. 点击"开始搜索"按钮',
    '3. 系统将自动提取图片特征并匹配',
    '4. 返回相似度最高的文物列表',
  ]

  async selectFromGallery() {
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

  async takePhoto() {
    try {
      const context = getContext(this)
      const pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      }
      const pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(
        context,
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      )
      if (pickerResult && pickerResult.resultCode === 0 && pickerResult.resultUri) {
        this.selectedImagePath = pickerResult.resultUri
      }
    } catch (e) {
    }
  }

  async copyToCache(sourceUri: string): Promise<string> {
    const context = getContext(this)
    const ext = sourceUri.split('.').pop()?.toLowerCase() || 'jpg'
    const fileName = `upload_${Date.now()}.${ext}`
    const cacheDir = context.cacheDir
    const destPath = `${cacheDir}/${fileName}`
    const srcFile = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY)
    const destFile = fs.openSync(destPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    fs.copyFileSync(srcFile.fd, destFile.fd)
    fs.closeSync(srcFile)
    fs.closeSync(destFile)
    return `internal://cache/${fileName}`
  }

  async startSearch() {
    if (!this.selectedImagePath) {
      return
    }
    this.isSearching = true
    this.hasSearched = true
    try {
      const uploadPath = await this.copyToCache(this.selectedImagePath)
      const context = getContext(this)
      const response = await httpUpload<ApiResponse<Artifact[]>>(API.IMAGE_SEARCH, uploadPath, context)
      if (response && response.data && Array.isArray(response.data)) {
        this.searchResults = response.data
      } else {
        this.searchResults = []
      }
      this.searchResults.sort((a: Artifact, b: Artifact) => (b.similarity || 0) - (a.similarity || 0))
    } catch (e) {
      this.searchResults = []
    }
    this.isSearching = false
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => { router.back() })

        Text('以图搜图')
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
            if (this.selectedImagePath) {
              Image(this.selectedImagePath)
                .width('100%')
                .height(240)
                .borderRadius(12)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#F5F5F5')
            } else {
              Column() {
                Text('📷')
                  .fontSize(64)
                Text('点击拍照或从相册选择')
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
              .justifyContent(FlexAlign.Center)
            }
          }
          .width('100%')
          .borderRadius(12)
          .backgroundColor('#FFFFFF')
          .border({ width: 2, color: '#E0E0E0', style: BorderStyle.Dashed })
          .margin({ left: 16, right: 16, top: 16 })

          Row() {
            Button('📷 拍照')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#C62828')
              .borderRadius(22)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .margin({ right: 8 })
              .onClick(() => { this.takePhoto() })

            Button('🖼️ 相册')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#FFFFFF')
              .borderRadius(22)
              .fontSize(16)
              .fontColor('#C62828')
              .border({ width: 1, color: '#C62828' })
              .margin({ left: 8 })
              .onClick(() => { this.selectFromGallery() })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })

          if (this.selectedImagePath) {
            Button('🔍 开始搜索')
              .width('90%')
              .height(48)
              .backgroundColor('#C62828')
              .borderRadius(24)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .margin({ top: 16 })
              .enabled(!this.isSearching)
              .onClick(() => { this.startSearch() })
          }

          if (this.isSearching) {
            Column() {
              LoadingProgress().width(40).height(40).color('#C62828')
              Text('正在提取特征并搜索相似文物...')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ top: 32 })
            .justifyContent(FlexAlign.Center)
          }

          if (this.hasSearched && !this.isSearching) {
            Text(`搜索结果 (${this.searchResults.length})`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ top: 16, bottom: 8 })
              .padding({ left: 16, right: 16 })

            if (this.searchResults.length === 0) {
              Column() {
                Text('未找到相似文物').fontSize(14).fontColor('#999999')
                Text('请尝试上传更清晰的文物图片').fontSize(12).fontColor('#CCCCCC').margin({ top: 4 })
              }
              .width('100%')
              .padding(24)
              .justifyContent(FlexAlign.Center)
            } else {
              ForEach(this.searchResults, (item: Artifact) => {
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
                    if (item.similarity !== undefined && item.similarity !== null) {
                      Text(`相似度: ${(item.similarity * 100).toFixed(1)}%`)
                        .fontSize(12)
                        .fontColor('#C62828')
                        .fontWeight(FontWeight.Bold)
                        .margin({ top: 2 })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: 12 })
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .margin({ bottom: 8 })
                .onClick(() => {
                  const routeParams: ArtifactRouteParams = { artifactId: item.id }
                  router.pushUrl({ url: 'pages/ArtifactDetailPage', params: routeParams })
                })
              })
            }
          }

          if (!this.hasSearched) {
            Column() {
              Text('使用说明')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .margin({ bottom: 12 })
              ForEach(this.searchSteps, (item: string) => {
                Text(item)
                  .fontSize(14)
                  .fontColor('#666666')
                  .width('100%')
                  .margin({ bottom: 8 })
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 16, right: 16, top: 16, bottom: 16 })
          }
        }
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
