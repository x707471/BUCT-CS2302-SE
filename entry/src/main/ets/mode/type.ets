export interface Artifact {
  id: number
  objectId: string
  titleZh: string
  titleEn: string
  timePeriod: string
  dynastyId: number
  type: string
  material: string
  description: string
  dimensions: string
  museumId: number
  museumName: string
  imageUrl: string
  imagePath: string
  detailUrl: string
  locationId: number
  imageValidated: number
  likesCount: number
  similarity?: number
  createdAt: string
}

export interface User {
  id: number
  username: string
  email: string
  phone: string
  nickname: string
  avatarUrl: string
  status: string
  source: string
  registeredAt: string
  lastLogin: string
}

export interface LoginResponse {
  code: number
  message: string
  data: User
}

export interface Comment {
  id: number
  userId: number
  artifactId: number
  content: string
  status: string
  parentId: number
  createdAt: string
  artifactName?: string
  artifactImageUrl?: string
}

export interface UserUpload {
  id: number
  userId: number
  artifactId: number
  mediaType: string
  fileUrl: string
  imagePath: string
  caption: string
  description: string
  status: string
  likeCount: number
  createdAt: string
}

export interface BrowseHistoryItem {
  id: number
  userId: number
  artifactId: number
  browseTime: string
  artifact: Artifact | null
}

export interface CollectionGroup {
  groupName: string
  count: number
}

export interface HotArtifactItem {
  id: number
  name: string
  era: string
  type: string
  museum: string
  imageUrl: string
}

export interface QuickActionItem {
  icon: string
  label: string
  action: () => void
}

export interface ApiResult<T> {
  code: number
  message: string
  data: T
}

export interface LoginRequest {
  username: string
  password: string
}

export interface RegisterRequest {
  username: string
  password: string
  email: string
  phone: string
}

export interface UserArtifactRequest {
  userId: number
  artifactId: number
}

export interface CommentRequest {
  userId: number
  artifactId: number
  content: string
}

export interface UserIdRequest {
  userId: number
}

export interface ArtifactRouteParams {
  artifactId: number
}

export interface FilterRouteParams {
  filter: string
  value: string
}

export interface TabRouteParams {
  tab: string
}

export interface UploadRequest {
  userId: number
  artifactId: number
  mediaType: string
  caption: string
}

export interface CollectionGroupRequest {
  userId: number
  artifactId: number
  groupName: string
}

export interface VoiceQaRequest {
  question: string
  artifactId?: number
}

export interface VoiceQaResponse {
  answer: string
}

export interface SearchParams {
  keyword: string
  type: string
  era: string
  material: string
  museumId: number
  sortBy: string
  page: number
  pageSize: number
}

export interface AdvancedSearchParams {
  keyword: string
  era: string
  type: string
  museum: string
  material: string
  sort: string
  page: number
  pageSize: number
}

export interface LikeCheckResult {
  liked: boolean
}

export interface CollectionCheckResult {
  collected: boolean
}

export interface ImageSearchRequest {
  imagePath: string
}

