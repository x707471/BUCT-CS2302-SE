import { router } from '@kit.ArkUI'
import { httpGetRaw } from '../common/utils/HttpUtil'
import { API } from '../common/constants/ApiConstants'
import { CommonConstants } from '../common/constants/CommonConstants'
import { Artifact, ArtifactRouteParams } from '../mode/type'
import { speechRecognizer } from '@kit.CoreSpeechKit'

@Entry
@Component
struct VoiceSearchPage {
  @State isListening: boolean = false
  @State recognizedText: string = ''
  @State searchText: string = ''
  @State searchResults: Artifact[] = []
  @State isLoading: boolean = false
  @State hasSearched: boolean = false
  @State asrSupported: boolean = true
  @State asrError: string = ''

  private asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null

  aboutToDisappear() {
    this.stopListening()
  }

  async startListening() {
    this.isListening = true
    this.recognizedText = ''
    this.asrError = ''
    try {
      const engineParams: speechRecognizer.CreateEngineParams = {
        language: 'zh-CN',
        online: 1,
      }
      this.asrEngine = await speechRecognizer.createEngine(engineParams)
      if (this.asrEngine) {
        const self = this
        const listener: speechRecognizer.RecognitionListener = {
          onStart(sessionId: string, eventMessage: string) {},
          onEvent(sessionId: string, eventCode: number, eventMessage: string) {},
          onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
            if (result.isLast && result.result) {
              self.recognizedText = result.result
              self.searchText = result.result
              self.isListening = false
              self.doSearch(result.result)
            }
          },
          onComplete(sessionId: string, eventMessage: string) {},
          onError(sessionId: string, errorCode: number, errorMessage: string) {
            self.isListening = false
            if (errorCode === 1002200007 || errorMessage.includes('not initialized') || errorMessage.includes('notinitialized')) {
              self.asrSupported = false
              self.asrError = '当前设备不支持语音识别，请使用文字搜索'
            } else {
              self.asrError = `语音识别错误: ${errorMessage}`
            }
          }
        }
        this.asrEngine.setListener(listener)
        this.asrEngine.startListening({
          sessionId: Date.now().toString(),
          audioInfo: {
            audioType: 'pcm',
            sampleRate: 16000,
            soundChannel: 1,
            sampleBit: 16,
          },
          extraParams: {},
        })
      }
    } catch (e) {
      this.isListening = false
      this.asrSupported = false
      this.asrError = '语音识别不可用，请使用文字搜索'
    }
  }

  stopListening() {
    if (this.asrEngine) {
      try {
        this.asrEngine.cancel('')
        this.asrEngine.shutdown()
        this.asrEngine = null
      } catch (e) {
      }
    }
    this.isListening = false
  }

  async doSearch(keyword: string) {
    if (!keyword.trim()) {
      return
    }
    this.isLoading = true
    this.hasSearched = true
    try {
      this.searchResults = await httpGetRaw<Artifact[]>(
        `${API.ARTIFACT_SEARCH}?keyword=${encodeURIComponent(keyword.trim())}`
      )
    } catch (e) {
      this.searchResults = []
    }
    this.isLoading = false
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => { router.back() })

        Text('语音搜索')
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
            Row() {
              TextInput({ placeholder: '输入关键词搜索文物', text: this.searchText })
                .layoutWeight(1)
                .height(40)
                .borderRadius(20)
                .backgroundColor('#F5F5F5')
                .onChange((value: string) => {
                  this.searchText = value
                })
                .onSubmit(() => {
                  this.doSearch(this.searchText)
                })

              Text('搜索')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#C62828')
                .borderRadius(20)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ left: 8 })
                .onClick(() => {
                  this.doSearch(this.searchText)
                })
            }
            .width('100%')
            .margin({ bottom: 20 })

            if (this.asrSupported) {
              Text(this.isListening ? '正在聆听...' : '点击麦克风开始语音搜索')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ bottom: 24 })

              Column() {
                Text('🎤')
                  .fontSize(48)
              }
              .width(100)
              .height(100)
              .borderRadius(50)
              .backgroundColor(this.isListening ? '#FFCDD2' : '#FFF5F5')
              .justifyContent(FlexAlign.Center)
              .shadow(this.isListening ? { radius: 20, color: '#C6282844', offsetY: 0 } : { radius: 0, color: '#00000000', offsetY: 0 })
              .onClick(() => {
                if (this.isListening) {
                  this.stopListening()
                } else {
                  this.startListening()
                }
              })

              if (this.asrError) {
                Text(this.asrError)
                  .fontSize(12)
                  .fontColor('#FF5722')
                  .margin({ top: 12 })
              }

              if (this.recognizedText) {
                Column() {
                  Text('识别结果：')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 16, bottom: 4 })
                  Text(this.recognizedText)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#C62828')
                }
                .margin({ top: 8 })
              }
            } else {
              Text('语音识别不可用，请使用上方搜索框输入关键词')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 16 })
            }
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Center)

          if (this.hasSearched) {
            Text(`搜索结果 (${this.searchResults.length})`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ top: 16, bottom: 8 })

            if (this.isLoading) {
              Column() {
                LoadingProgress().width(40).height(40).color('#C62828')
              }
              .width('100%')
              .padding(24)
              .justifyContent(FlexAlign.Center)
            } else if (this.searchResults.length === 0) {
              Column() {
                Text('未找到相关文物').fontSize(14).fontColor('#999999')
              }
              .width('100%')
              .padding(24)
              .justifyContent(FlexAlign.Center)
            } else {
              ForEach(this.searchResults, (item: Artifact) => {
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
                .borderRadius(8)
                .margin({ bottom: 8 })
                .onClick(() => {
                  const routeParams: ArtifactRouteParams = { artifactId: item.id }
                  router.pushUrl({ url: 'pages/ArtifactDetailPage', params: routeParams })
                })
              })
            }
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
