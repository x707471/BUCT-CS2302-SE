export const BASE_URL: string = 'http://172.28.128.1:5000'

export class ApiConfig {
  static readonly USER_LOGIN: string = `${BASE_URL}/api/user/login`
  static readonly USER_REGISTER: string = `${BASE_URL}/api/user/register`
  static readonly USER_INFO = (userId: number): string => `${BASE_URL}/api/user/info/${userId}`
  static readonly USER_UPDATE: string = `${BASE_URL}/api/user/update`
  static readonly USER_DELETE = (userId: number): string => `${BASE_URL}/api/user/delete/${userId}`

  static readonly ARTIFACTS: string = `${BASE_URL}/api/artifacts/`
  static readonly ARTIFACT_DETAIL = (id: number): string => `${BASE_URL}/api/artifacts/${id}`
  static readonly ARTIFACT_SEARCH: string = `${BASE_URL}/api/artifacts/search`
  static readonly ARTIFACT_ADVANCED_SEARCH: string = `${BASE_URL}/api/artifacts/advanced-search`
  static readonly ARTIFACT_BY_ERA = (era: string): string => `${BASE_URL}/api/artifacts/era/${era}`
  static readonly ARTIFACT_BY_TYPE = (type: string): string => `${BASE_URL}/api/artifacts/type/${type}`
  static readonly ARTIFACT_BY_MUSEUM = (museum: string): string => `${BASE_URL}/api/artifacts/museum/${museum}`
  static readonly ARTIFACT_LIKES = (id: number): string => `${BASE_URL}/api/artifacts/likes/${id}`
  static readonly ARTIFACT_HOT: string = `${BASE_URL}/api/artifacts/hot`

  static readonly ARTIFACT_AUDIO = (artifactId: number): string => `${BASE_URL}/api/artifacts/${artifactId}/audio`

  static readonly COLLECTIONS: string = `${BASE_URL}/api/user/collections`
  static readonly COLLECTION_ADD: string = `${BASE_URL}/api/collection/add`
  static readonly COLLECTION_REMOVE: string = `${BASE_URL}/api/collection/remove`
  static readonly COLLECTION_CHECK: string = `${BASE_URL}/api/collection/check`
  static readonly COLLECTION_GROUPS = (userId: number): string => `${BASE_URL}/api/collection/groups/${userId}`
  static readonly COLLECTION_MOVE_GROUP: string = `${BASE_URL}/api/collection/move-group`

  static readonly LIKES: string = `${BASE_URL}/api/user/likes`
  static readonly LIKE_ADD: string = `${BASE_URL}/api/like/add`
  static readonly LIKE_REMOVE: string = `${BASE_URL}/api/like/remove`
  static readonly LIKE_CHECK: string = `${BASE_URL}/api/like/check`
  static readonly ARTIFACT_LIKES_COUNT = (id: number): string => `${BASE_URL}/api/artifacts/likes/${id}`

  static readonly COMMENTS: string = `${BASE_URL}/api/comments/`
  static readonly COMMENT_UPDATE_STATUS = (id: number): string => `${BASE_URL}/api/comments/${id}/status`
  static readonly COMMENT_DELETE = (id: number): string => `${BASE_URL}/api/comments/${id}`
  static readonly COMMENT_UPDATE = (id: number): string => `${BASE_URL}/api/comments/${id}`
  static readonly USER_COMMENTS = (userId: number): string => `${BASE_URL}/api/comments/user/${userId}`

  static readonly BROWSE_HISTORY: string = `${BASE_URL}/api/browse-history/`
  static readonly BROWSE_HISTORY_ADD: string = `${BASE_URL}/api/browse-history/add`
  static readonly BROWSE_HISTORY_DELETE = (id: number): string => `${BASE_URL}/api/browse-history/${id}`
  static readonly BROWSE_HISTORY_CLEAR: string = `${BASE_URL}/api/browse-history/clear`

  static readonly IMAGE_SEARCH: string = `${BASE_URL}/api/artifacts/search/image`
  static readonly HEALTH_CHECK: string = `${BASE_URL}/api/health`

  static readonly UPLOAD: string = `${BASE_URL}/api/uploads/`
  static readonly UPLOAD_ADD: string = `${BASE_URL}/api/uploads/add`
  static readonly USER_UPLOADS = (userId: number): string => `${BASE_URL}/api/uploads/user/${userId}`

  static readonly VOICE_QA: string = `${BASE_URL}/api/qa/ask`
}

export const API = ApiConfig
