import http from '@ohos.net.http'
import { request } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'

export interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export function httpRequest<T>(url: string, method: http.RequestMethod = http.RequestMethod.GET,
  data?: object): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const httpRequest = http.createHttp()
    const options: http.HttpRequestOptions = {
      method: method,
      header: {
        'Content-Type': 'application/json',
      },
      expectDataType: http.HttpDataType.OBJECT,
      connectTimeout: 10000,
      readTimeout: 10000,
    }
    if (data) {
      options.extraData = data
    }
    httpRequest.request(url, options, (err, response) => {
      if (!err && response.responseCode === 200) {
        const result = response.result as ApiResponse<T>
        if (result.code === 200) {
          resolve(result.data)
        } else {
          reject(new Error(result.message || '请求失败'))
        }
      } else if (!err && response.responseCode === 201) {
        resolve(response.result as T)
      } else if (!err && response.responseCode === 204) {
        resolve(null as T)
      } else {
        reject(new Error(err ? err.message : `HTTP ${response.responseCode}`))
      }
      httpRequest.destroy()
    })
  })
}

export function httpGetRaw<T>(url: string): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const httpRequest = http.createHttp()
    httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: { 'Content-Type': 'application/json' },
      expectDataType: http.HttpDataType.OBJECT,
      connectTimeout: 10000,
      readTimeout: 10000,
    }, (err, response) => {
      if (!err && response.responseCode === 200) {
        resolve(response.result as T)
      } else if (!err && response.result && typeof response.result === 'object') {
        const result = response.result as Record<string, string>
        reject(new Error(result['message'] || `HTTP ${response.responseCode}`))
      } else {
        reject(new Error(err ? err.message : `HTTP ${response.responseCode}`))
      }
      httpRequest.destroy()
    })
  })
}

export function httpPostRaw<T>(url: string, data: object): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const httpRequest = http.createHttp()
    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: data,
      expectDataType: http.HttpDataType.OBJECT,
      connectTimeout: 10000,
      readTimeout: 10000,
    }, (err, response) => {
      if (!err && (response.responseCode === 200 || response.responseCode === 201)) {
        resolve(response.result as T)
      } else if (!err && response.result && typeof response.result === 'object') {
        const result = response.result as Record<string, string>
        reject(new Error(result['message'] || `HTTP ${response.responseCode}`))
      } else {
        reject(new Error(err ? err.message : `HTTP ${response.responseCode}`))
      }
      httpRequest.destroy()
    })
  })
}

export function httpPutRaw<T>(url: string, data: object): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const httpRequest = http.createHttp()
    httpRequest.request(url, {
      method: http.RequestMethod.PUT,
      header: { 'Content-Type': 'application/json' },
      extraData: data,
      expectDataType: http.HttpDataType.OBJECT,
      connectTimeout: 10000,
      readTimeout: 10000,
    }, (err, response) => {
      if (!err && response.responseCode === 200) {
        resolve(response.result as T)
      } else if (!err && response.result && typeof response.result === 'object') {
        const result = response.result as Record<string, string>
        reject(new Error(result['message'] || `HTTP ${response.responseCode}`))
      } else {
        reject(new Error(err ? err.message : `HTTP ${response.responseCode}`))
      }
      httpRequest.destroy()
    })
  })
}

export function httpUpload<T>(url: string, internalFilePath: string, context: Context, formData?: Record<string, string>): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const ext = internalFilePath.split('.').pop()?.toLowerCase() || 'jpg'
    const contentTypeMap: Record<string, string> = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'bmp': 'image/bmp',
      'webp': 'image/webp',
      'gif': 'image/gif',
    }
    const mimeType = contentTypeMap[ext] || 'image/jpeg'
    const fileName = `upload_${Date.now()}.${ext}`
    const abilityContext = context as common.UIAbilityContext
    const files: Array<request.File> = [
      {
        name: 'file',
        uri: internalFilePath,
        filename: fileName,
        type: mimeType
      }
    ]
    const dataItems: Array<request.RequestData> = []
    if (formData) {
      const keys = Object.keys(formData)
      for (let i = 0; i < keys.length; i++) {
        dataItems.push({ name: keys[i], value: formData[keys[i]] })
      }
    }
    const uploadConfig: request.UploadConfig = {
      url: url,
      method: 'POST',
      header: { 'Content-Type': 'multipart/form-data' },
      files: files,
      data: dataItems
    }
    request.uploadFile(abilityContext, uploadConfig, (err, uploadTask) => {
      if (err) {
        reject(new Error(err.message))
        return
      }
      if (!uploadTask) {
        reject(new Error('uploadTask is null'))
        return
      }
      let responseBody: string = ''
      uploadTask.on('headerReceive', (header: object) => {
        const headerObj = header as Record<string, string>
        if (headerObj['body']) {
          responseBody = headerObj['body']
        }
      })
      uploadTask.on('complete', () => {
        if (responseBody) {
          try {
            const result = JSON.parse(responseBody) as T
            resolve(result)
          } catch (parseErr) {
            reject(new Error('response parse error'))
          }
        } else {
          reject(new Error('empty response'))
        }
      })
      uploadTask.on('fail', (taskStates: Array<request.TaskState>) => {
        reject(new Error('upload failed'))
      })
    })
  })
}
