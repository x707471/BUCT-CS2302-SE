import { media } from '@kit.MediaKit'
import { BusinessError } from '@kit.BasicServicesKit'

export class AudioPlayerManager {
  private avPlayer: media.AVPlayer | null = null
  private currentUrl: string = ''
  private lastState: string = 'idle'

  public onProgressChange: (currentMs: number, totalMs: number) => void = () => {
  }
  public onStateChange: (state: string) => void = () => {
  }

  async initPlayer() {
    this.avPlayer = await media.createAVPlayer()
    this.initPlayerListeners()
  }

  private initPlayerListeners() {
    if (!this.avPlayer) {
      return
    }

    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      this.lastState = state
      this.onStateChange(state)
      switch (state) {
        case 'initialized':
          this.avPlayer?.prepare()
          break
        case 'prepared':
          this.avPlayer?.play()
          break
        case 'completed':
          if (this.avPlayer) {
            this.onProgressChange(this.avPlayer.duration, this.avPlayer.duration)
          }
          break
        case 'error':
          try {
            await this.avPlayer?.reset()
          } catch (e) {
          }
          break
        default:
          break
      }
    })

    this.avPlayer.on('timeUpdate', (time: number) => {
      if (this.avPlayer) {
        this.onProgressChange(time, this.avPlayer.duration)
      }
    })

    this.avPlayer.on('error', (err: BusinessError) => {
      this.onStateChange('error')
    })
  }

  public async playUrl(url: string) {
    if (!this.avPlayer) {
      return
    }
    this.currentUrl = url
    try {
      await this.avPlayer.reset()
      this.avPlayer.url = url
    } catch (e) {
      this.onStateChange('error')
    }
  }

  public async replay() {
    if (this.currentUrl) {
      await this.playUrl(this.currentUrl)
    }
  }

  public play() {
    if (!this.avPlayer) {
      return
    }
    if (this.lastState === 'error' || this.lastState === 'idle' || this.lastState === 'completed') {
      if (this.currentUrl) {
        this.playUrl(this.currentUrl)
        return
      }
    }
    this.avPlayer.play()
  }

  public pause() {
    this.avPlayer?.pause()
  }

  public stop() {
    this.avPlayer?.stop()
  }

  public seek(timeMs: number) {
    this.avPlayer?.seek(timeMs)
  }

  public setSpeed(speed: number) {
    if (!this.avPlayer) {
      return
    }
    let speedMode: media.PlaybackSpeed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X
    if (speed === 0.5) {
      speedMode = media.PlaybackSpeed.SPEED_FORWARD_0_50_X
    } else if (speed === 0.75) {
      speedMode = media.PlaybackSpeed.SPEED_FORWARD_0_75_X
    } else if (speed === 1.0) {
      speedMode = media.PlaybackSpeed.SPEED_FORWARD_1_00_X
    } else if (speed === 1.25) {
      speedMode = media.PlaybackSpeed.SPEED_FORWARD_1_25_X
    } else if (speed === 1.5) {
      speedMode = media.PlaybackSpeed.SPEED_FORWARD_1_50_X
    } else if (speed === 2.0) {
      speedMode = media.PlaybackSpeed.SPEED_FORWARD_2_00_X
    }
    this.avPlayer.setSpeed(speedMode)
  }

  public getDuration(): number {
    return this.avPlayer?.duration ?? 0
  }

  public getCurrentTime(): number {
    return this.avPlayer?.currentTime ?? 0
  }

  public release() {
    if (this.avPlayer) {
      this.avPlayer.off('stateChange')
      this.avPlayer.off('timeUpdate')
      this.avPlayer.off('error')
      this.avPlayer.release()
      this.avPlayer = null
    }
  }
}
