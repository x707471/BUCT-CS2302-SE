import { preferences } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'

const USER_PREF_NAME = 'museum_user_pref'
const KEY_USER_ID = 'user_id'
const KEY_USERNAME = 'username'
const KEY_IS_LOGGED_IN = 'is_logged_in'

export class UserService {
  private static instance: UserService
  private pref: preferences.Preferences | null = null
  public userId: number = -1
  public username: string = ''
  public isLoggedIn: boolean = false

  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService()
    }
    return UserService.instance
  }

  async init(context: Context): Promise<void> {
    this.pref = await preferences.getPreferences(context, USER_PREF_NAME)
    this.userId = (await this.pref.get(KEY_USER_ID, -1)) as number
    this.username = (await this.pref.get(KEY_USERNAME, '')) as string
    this.isLoggedIn = (await this.pref.get(KEY_IS_LOGGED_IN, false)) as boolean
  }

  async login(userId: number, username: string): Promise<void> {
    this.userId = userId
    this.username = username
    this.isLoggedIn = true
    if (this.pref) {
      await this.pref.put(KEY_USER_ID, userId)
      await this.pref.put(KEY_USERNAME, username)
      await this.pref.put(KEY_IS_LOGGED_IN, true)
      await this.pref.flush()
    }
  }

  async logout(): Promise<void> {
    this.userId = -1
    this.username = ''
    this.isLoggedIn = false
    if (this.pref) {
      await this.pref.put(KEY_USER_ID, -1)
      await this.pref.put(KEY_USERNAME, '')
      await this.pref.put(KEY_IS_LOGGED_IN, false)
      await this.pref.flush()
    }
  }
}
