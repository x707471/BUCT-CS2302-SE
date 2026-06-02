import { BASE_URL } from './ApiConstants'

export class CommonConstants {
  static readonly TAB_HOME = 0
  static readonly TAB_EXPLORE = 1
  static readonly TAB_SEARCH = 2
  static readonly TAB_PROFILE = 3

  static readonly PAGE_SIZE = 20

  static readonly ERA_LIST: string[] = ['全部', '商代', '西周', '春秋', '战国', '秦代', '西汉', '东汉', '唐代', '北宋', '元代', '清代']
  static readonly TYPE_LIST: string[] = ['全部', '青铜器', '瓷器', '书画', '玉器', '陶器', '兵器', '乐器']
  static readonly MUSEUM_LIST: string[] = ['全部', '中国国家博物馆', '故宫博物院', '湖北省博物馆', '甘肃省博物馆', '河北博物院', '秦始皇帝陵博物院', '台北故宫博物院']
  static readonly MATERIAL_LIST: string[] = ['全部', '青铜', '瓷', '纸', '绢', '玉', '陶', '铁', '金', '银']

  static readonly SORT_OPTIONS: string[] = ['默认', '热度', '年代', '最新']
  static readonly SORT_VALUES: string[] = ['default', 'hot', 'era', 'newest']

  static resolveImageUrl(url: string): string {
    if (!url) return ''
    if (url.startsWith('http')) return url
    return `${BASE_URL}${url}`
  }
}
