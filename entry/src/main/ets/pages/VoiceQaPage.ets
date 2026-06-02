import { router } from '@kit.ArkUI'
import { httpPostRaw } from '../common/utils/HttpUtil'
import { API } from '../common/constants/ApiConstants'
import { VoiceQaRequest, VoiceQaResponse } from '../mode/type'
import { speechRecognizer } from '@kit.CoreSpeechKit'

@Entry
@Component
struct VoiceQaPage {
  @State question: string = ''
  @State answer: string = ''
  @State isLoading: boolean = false
  @State isListening: boolean = false
  @State artifactId: number = 0

  private asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null

  private asrListener: speechRecognizer.RecognitionListener = {
    onStart(sessionId: string, eventMessage: string) {},
    onEvent(sessionId: string, eventCode: number, eventMessage: string) {},
    onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
      if (result.isLast && result.result) {
        this.question = result.result
        this.isListening = false
        this.submitQuestion()
      }
    },
    onComplete(sessionId: string, eventMessage: string) {},
    onError(sessionId: string, errorCode: number, errorMessage: string) {
      this.isListening = false
    }
  };

  async aboutToAppear() {
    const params = router.getParams() as Record<string, number>
    if (params && params['artifactId']) {
      this.artifactId = params['artifactId']
    }
  }

  aboutToDisappear() {
    this.stopListening()
  }

  async startListening() {
    this.isListening = true
    try {
      const engineParams: speechRecognizer.CreateEngineParams = {
        language: 'zh-CN',
        online: 1,
      }
      this.asrEngine = await speechRecognizer.createEngine(engineParams)
      if (this.asrEngine) {
        this.asrEngine.setListener(this.asrListener)
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
    }
  }

  stopListening() {
    if (this.asrEngine) {
      try {
        this.asrEngine.cancel("")
        this.asrEngine.shutdown()
        this.asrEngine = null
      } catch (e) {
      }
    }
    this.isListening = false
  }

  async submitQuestion() {
    if (!this.question.trim()) {
      return
    }
    this.isLoading = true
    this.answer = ''
    try {
      const qaRequest: VoiceQaRequest = {
        question: this.question,
        artifactId: this.artifactId,
      }
      const result = await httpPostRaw<VoiceQaResponse>(API.VOICE_QA, qaRequest)
      this.answer = result.answer || '暂无回答'
    } catch (e) {
      this.answer = '获取回答失败，请检查网络连接'
    }
    this.isLoading = false
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => { router.back() })

        Text('智能问答')
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
            Text('向AI助手提问关于文物的问题')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 16 })

            Row() {
              TextInput({ placeholder: '输入你的问题...' })
                .layoutWeight(1)
                .height(44)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .onChange((value: string) => { this.question = value })

              Column() {
                Text('🎤')
                  .fontSize(24)
              }
              .width(44)
              .height(44)
              .borderRadius(22)
              .backgroundColor(this.isListening ? '#FFCDD2' : '#FFF5F5')
              .justifyContent(FlexAlign.Center)
              .margin({ left: 8 })
              .onClick(() => {
                if (this.isListening) {
                  this.stopListening()
                } else {
                  this.startListening()
                }
              })
            }

            Button('提问')
              .width('100%')
              .height(44)
              .backgroundColor('#C62828')
              .fontColor('#FFFFFF')
              .borderRadius(22)
              .margin({ top: 12 })
              .enabled(!this.isLoading && this.question.trim() !== '')
              .onClick(() => { this.submitQuestion() })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          if (this.isLoading) {
            Column() {
              LoadingProgress().width(40).height(40).color('#C62828')
              Text('AI正在思考...').fontSize(14).fontColor('#999999').margin({ top: 8 })
            }
            .width('100%')
            .padding(32)
            .justifyContent(FlexAlign.Center)
          }

          if (this.answer) {
            Column() {
              Row() {
                Text('🤖 AI回答')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
              }
              .width('100%')
              .margin({ bottom: 12 })

              Text(this.answer)
                .fontSize(15)
                .fontColor('#333333')
                .lineHeight(24)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ top: 16 })
          }

          Column() {
            Text('推荐问题')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 8 })

            ForEach(['这件文物是什么年代的？', '这件文物的历史意义是什么？', '这件文物是如何制作的？', '这件文物在哪里出土的？'], (q: string) => {
              Text(q)
                .fontSize(14)
                .fontColor('#C62828')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor('#FFF5F5')
                .borderRadius(8)
                .margin({ bottom: 8 })
                .width('100%')
                .onClick(() => {
                  this.question = q
                  this.submitQuestion()
                })
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 16 })
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
