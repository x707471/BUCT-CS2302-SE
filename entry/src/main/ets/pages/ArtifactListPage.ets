import { router } from '@kit.ArkUI'
import { httpGetRaw, httpPostRaw } from '../common/utils/HttpUtil'
import { CommonConstants } from '../common/constants/CommonConstants'
import { API } from '../common/constants/ApiConstants'
import { Artifact, ArtifactRouteParams, FilterRouteParams, AdvancedSearchParams } from '../mode/type'

@Entry
@Component
struct ArtifactListPage {
  @State artifacts: Artifact[] = []
  @State isLoading: boolean = true
  @State searchKeyword: string = ''
  @State currentSort: number = 0
  @State currentPage: number = 1
  @State hasMore: boolean = true
  @State selectedEra: string = ''
  @State selectedType: string = ''
  @State selectedMuseum: string = ''
  @State selectedMaterial: string = ''
  @State showFilterPanel: boolean = false
  @State activeFilterTab: number = 0

  private filterTabs: string[] = ['年代', '类型', '博物馆', '材质']

  async aboutToAppear() {
    const params = router.getParams() as FilterRouteParams
    if (params) {
      const filterFromParams: string = params.filter || ''
      const filterValueFromParams: string = params.value || ''
      if (filterFromParams === 'era') {
        this.selectedEra = filterValueFromParams
      } else if (filterFromParams === 'type') {
        this.selectedType = filterValueFromParams
      } else if (filterFromParams === 'museum') {
        this.selectedMuseum = filterValueFromParams
      }
    }
    await this.loadArtifacts(true)
  }

  getFilterCount(): number {
    let count: number = 0
    if (this.selectedEra) count++
    if (this.selectedType) count++
    if (this.selectedMuseum) count++
    if (this.selectedMaterial) count++
    return count
  }

  async loadArtifacts(reset: boolean) {
    if (reset) {
      this.currentPage = 1
      this.artifacts = []
      this.hasMore = true
    }
    this.isLoading = true
    try {
      const hasFilter: boolean = !!(this.searchKeyword || this.selectedEra || this.selectedType ||
        this.selectedMuseum || this.selectedMaterial || this.currentSort > 0)
      let result: Artifact[] = []
      if (hasFilter) {
        const searchParams: AdvancedSearchParams = {
          keyword: this.searchKeyword,
          era: this.selectedEra,
          type: this.selectedType,
          museum: this.selectedMuseum,
          material: this.selectedMaterial,
          sort: CommonConstants.SORT_VALUES[this.currentSort],
          page: this.currentPage,
          pageSize: CommonConstants.PAGE_SIZE,
        }
        result = await httpPostRaw<Artifact[]>(API.ARTIFACT_ADVANCED_SEARCH, searchParams as object)
      } else {
        result = await httpGetRaw<Artifact[]>(API.ARTIFACTS)
      }
      if (reset) {
        this.artifacts = result
      } else {
        this.artifacts = [...this.artifacts, ...result]
      }
      this.hasMore = result.length >= CommonConstants.PAGE_SIZE
    } catch (e) {
      if (reset) {
        this.artifacts = []
      }
    }
    this.isLoading = false
  }

  build() {
    Column() {
      this.SearchBar()
      this.FilterBar()
      this.ActiveFilters()
      if (this.showFilterPanel) {
        this.FilterPanel()
      }
      this.ArtifactListContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  SearchBar() {
    Row() {
      Image($r('sys.media.ohos_ic_public_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => { router.back() })

      TextInput({ placeholder: '搜索文物名称、年代、类型...', text: this.searchKeyword })
        .layoutWeight(1)
        .height(40)
        .margin({ left: 8, right: 8 })
        .borderRadius(20)
        .backgroundColor('#F5F5F5')
        .onChange((value: string) => { this.searchKeyword = value })
        .onSubmit(() => { this.loadArtifacts(true) })

      Text('搜索')
        .fontSize(14)
        .fontColor('#C62828')
        .fontWeight(FontWeight.Medium)
        .padding({ left: 4, right: 4, top: 8, bottom: 8 })
        .onClick(() => { this.loadArtifacts(true) })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  FilterBar() {
    Row() {
      ForEach(CommonConstants.SORT_OPTIONS, (option: string, index: number) => {
        Text(option)
          .fontSize(13)
          .fontColor(this.currentSort === index ? '#C62828' : '#666666')
          .fontWeight(this.currentSort === index ? FontWeight.Bold : FontWeight.Normal)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .onClick(() => {
            this.currentSort = index
            this.loadArtifacts(true)
          })
      })
      Blank()
      Row() {
        Text('筛选')
          .fontSize(14)
          .fontColor(this.showFilterPanel ? '#C62828' : '#333333')
          .fontWeight(FontWeight.Medium)
        if (this.getFilterCount() > 0) {
          Text(`${this.getFilterCount()}`)
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor('#C62828')
            .borderRadius(8)
            .width(16)
            .height(16)
            .textAlign(TextAlign.Center)
            .margin({ left: 4 })
        }
        Image(this.showFilterPanel ? $r('sys.media.ohos_ic_public_arrow_up') :
        $r('sys.media.ohos_ic_public_arrow_down'))
          .width(14)
          .height(14)
          .fillColor(this.showFilterPanel ? '#C62828' : '#999999')
          .margin({ left: 2 })
      }
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .borderRadius(16)
      .backgroundColor(this.showFilterPanel ? '#FFF5F5' : '#F0F0F0')
      .onClick(() => { this.showFilterPanel = !this.showFilterPanel })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  ActiveFilters() {
    if (this.getFilterCount() > 0) {
      Scroll() {
        Row({ space: 8 }) {
          if (this.selectedEra) {
            Row({ space: 4 }) {
              Text(`年代: ${this.selectedEra}`)
                .fontSize(12)
                .fontColor('#C62828')
              Text('×')
                .fontSize(14)
                .fontColor('#C62828')
                .fontWeight(FontWeight.Bold)
            }
            .padding({ left: 10, right: 6, top: 4, bottom: 4 })
            .borderRadius(14)
            .backgroundColor('#FFF5F5')
            .border({ width: 0.5, color: '#FFCDD2' })
            .onClick(() => {
              this.selectedEra = ''
              this.loadArtifacts(true)
            })
          }
          if (this.selectedType) {
            Row({ space: 4 }) {
              Text(`类型: ${this.selectedType}`)
                .fontSize(12)
                .fontColor('#C62828')
              Text('×')
                .fontSize(14)
                .fontColor('#C62828')
                .fontWeight(FontWeight.Bold)
            }
            .padding({ left: 10, right: 6, top: 4, bottom: 4 })
            .borderRadius(14)
            .backgroundColor('#FFF5F5')
            .border({ width: 0.5, color: '#FFCDD2' })
            .onClick(() => {
              this.selectedType = ''
              this.loadArtifacts(true)
            })
          }
          if (this.selectedMuseum) {
            Row({ space: 4 }) {
              Text(`博物馆: ${this.selectedMuseum}`)
                .fontSize(12)
                .fontColor('#C62828')
              Text('×')
                .fontSize(14)
                .fontColor('#C62828')
                .fontWeight(FontWeight.Bold)
            }
            .padding({ left: 10, right: 6, top: 4, bottom: 4 })
            .borderRadius(14)
            .backgroundColor('#FFF5F5')
            .border({ width: 0.5, color: '#FFCDD2' })
            .onClick(() => {
              this.selectedMuseum = ''
              this.loadArtifacts(true)
            })
          }
          if (this.selectedMaterial) {
            Row({ space: 4 }) {
              Text(`材质: ${this.selectedMaterial}`)
                .fontSize(12)
                .fontColor('#C62828')
              Text('×')
                .fontSize(14)
                .fontColor('#C62828')
                .fontWeight(FontWeight.Bold)
            }
            .padding({ left: 10, right: 6, top: 4, bottom: 4 })
            .borderRadius(14)
            .backgroundColor('#FFF5F5')
            .border({ width: 0.5, color: '#FFCDD2' })
            .onClick(() => {
              this.selectedMaterial = ''
              this.loadArtifacts(true)
            })
          }
          Text('清除全部')
            .fontSize(12)
            .fontColor('#C62828')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              this.selectedEra = ''
              this.selectedType = ''
              this.selectedMuseum = ''
              this.selectedMaterial = ''
              this.loadArtifacts(true)
            })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor('#FFFFFF')
    }
  }

  @Builder
  FilterPanel() {
    Column() {
      Row() {
        ForEach(this.filterTabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontColor(this.activeFilterTab === index ? '#C62828' : '#666666')
              .fontWeight(this.activeFilterTab === index ? FontWeight.Bold : FontWeight.Normal)
            if (this.activeFilterTab === index) {
              Divider()
                .width(20)
                .height(2)
                .color('#C62828')
                .margin({ top: 4 })
            }
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 4 })
          .onClick(() => { this.activeFilterTab = index })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      Divider().width('100%').color('#F0F0F0')

      if (this.activeFilterTab === 0) {
        this.EraOptions()
      } else if (this.activeFilterTab === 1) {
        this.TypeOptions()
      } else if (this.activeFilterTab === 2) {
        this.MuseumOptions()
      } else if (this.activeFilterTab === 3) {
        this.MaterialOptions()
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ bottom: 12 })
  }

  @Builder
  EraOptions() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(CommonConstants.ERA_LIST, (item: string) => {
        Text(item)
          .fontSize(13)
          .fontColor(item === this.selectedEra ? '#FFFFFF' : '#666666')
          .backgroundColor(item === this.selectedEra ? '#C62828' : '#F0F0F0')
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .margin({ left: 8, top: 8 })
          .onClick(() => {
            this.selectedEra = item === this.selectedEra ? '' : item
            this.loadArtifacts(true)
          })
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8 })
  }

  @Builder
  TypeOptions() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(CommonConstants.TYPE_LIST, (item: string) => {
        Text(item)
          .fontSize(13)
          .fontColor(item === this.selectedType ? '#FFFFFF' : '#666666')
          .backgroundColor(item === this.selectedType ? '#C62828' : '#F0F0F0')
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .margin({ left: 8, top: 8 })
          .onClick(() => {
            this.selectedType = item === this.selectedType ? '' : item
            this.loadArtifacts(true)
          })
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8 })
  }

  @Builder
  MuseumOptions() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(CommonConstants.MUSEUM_LIST, (item: string) => {
        Text(item)
          .fontSize(13)
          .fontColor(item === this.selectedMuseum ? '#FFFFFF' : '#666666')
          .backgroundColor(item === this.selectedMuseum ? '#C62828' : '#F0F0F0')
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .margin({ left: 8, top: 8 })
          .onClick(() => {
            this.selectedMuseum = item === this.selectedMuseum ? '' : item
            this.loadArtifacts(true)
          })
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8 })
  }

  @Builder
  MaterialOptions() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(CommonConstants.MATERIAL_LIST, (item: string) => {
        Text(item)
          .fontSize(13)
          .fontColor(item === this.selectedMaterial ? '#FFFFFF' : '#666666')
          .backgroundColor(item === this.selectedMaterial ? '#C62828' : '#F0F0F0')
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .margin({ left: 8, top: 8 })
          .onClick(() => {
            this.selectedMaterial = item === this.selectedMaterial ? '' : item
            this.loadArtifacts(true)
          })
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8 })
  }

  @Builder
  ArtifactListContent() {
    if (this.isLoading && this.artifacts.length === 0) {
      Column() {
        LoadingProgress().width(40).height(40).color('#C62828')
        Text('加载中...').fontSize(14).fontColor('#999999').margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.artifacts.length === 0) {
      Column() {
        Text('暂无文物数据').fontSize(16).fontColor('#999999')
        Text('尝试调整搜索条件').fontSize(14).fontColor('#CCCCCC').margin({ top: 8 })
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
                  .width(100)
                  .height(100)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
              } else {
                Column() {
                  Text('🏛️').fontSize(32)
                }
                .width(100)
                .height(100)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .justifyContent(FlexAlign.Center)
              }
              Column() {
                Text(item.titleZh || item.titleEn)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .maxLines(2)
                Text(`${item.timePeriod || '未知年代'} · ${item.type || '未知类型'}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
                Text(item.material || '')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 2 })
                Row() {
                  Text(item.museumName || '')
                    .fontSize(11)
                    .fontColor('#C62828')
                    .backgroundColor('#FFF5F5')
                    .borderRadius(4)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  if (item.likesCount > 0) {
                    Text(`❤️ ${item.likesCount}`)
                      .fontSize(11)
                      .fontColor('#999999')
                      .margin({ left: 8 })
                  }
                }
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

        if (this.hasMore) {
          ListItem() {
            Row() {
              if (this.isLoading) {
                LoadingProgress().width(24).height(24).color('#C62828')
                Text('加载更多...').fontSize(14).fontColor('#999999').margin({ left: 8 })
              } else {
                Text('点击加载更多').fontSize(14).fontColor('#C62828')
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(16)
            .onClick(() => {
              if (!this.isLoading) {
                this.currentPage++
                this.loadArtifacts(false)
              }
            })
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      .scrollBar(BarState.Off)
    }
  }
}
