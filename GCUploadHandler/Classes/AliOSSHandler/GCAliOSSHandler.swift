//
//  GCAliOSSHandler.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/27.
//

import Foundation
import AliyunOSSiOS

/// 阿里云配置完成回调
public typealias AliOSSHandlerConfigCompletion = (_ error: GCAliOSSError?) -> Void
/// 阿里云上传完成回调
public typealias AliOSSHandlerUploadCompletion = (_ urlPath: String, _ error: GCAliOSSError?) -> Void
/// 阿里云上传多个文件完成回调
public typealias AliOSSHandlerUploadFilesCompletion = (_ urlPaths: [String], _ error: GCAliOSSError?) -> Void

/// 阿里云上传服务
public class GCAliOSSHandler {
    
    /// 单例
    public static let shared = GCAliOSSHandler()
    private init() {
    }
    /// 配置
    private var _config: GCAliOSSConfig?
    var config: GCAliOSSConfig? {
        get {
            _config
        }
        set {
            _config = newValue
        }
    }
    /// 请求
    private let _presenter = GCAliOSSPresenter()
    ///
    private var _ossClient : OSSClient?
    /// 上传服务是否准备好
    public var IsPrepare: Bool {
        if let _ = _ossClient {
            return true
        } else {
            return false
        }
    }
    
    /// 检查配置参数
    private func checkServerParams() {
        
        assert(_config != nil, "Config can't be nil")
    }
    
    /// 配置阿里云上传服务
    /// - Parameters:
    ///   - config: 配置参数
    ///   - completion: 完成回调
    public func config(config: GCAliOSSConfig, completion: AliOSSHandlerConfigCompletion?) {
        
        _config = config
        _presenter.aliConfig(config.oss_sts_server) { content in
 
            if let data = content?["data"] as? [String : Any],
            let accessKeyId = data["AccessKeyId"] as? String,
            let accessKeySecret = data["AccessKeySecret"] as? String,
            let securityToken = data["SecurityToken"] as? String,
            let statusCode = data["StatusCode"] as? String, statusCode == "200" {
                self.configCredential(accessKeyId, accessKeySecret, securityToken, completion)
            }
        } failed: { _ in
            completion?(GCAliOSSError.accessConfigError(.requestFailure(urlString: config.oss_sts_server)))
        }
    }
    
    /// 配置上传证书
    /// - Parameters:
    ///   - accessKeyId: AccessKeyId
    ///   - accessKeySecrect: AccessKeySecrect
    ///   - securityToken: SecurityToken
    ///   - completion: 配置完成回调
    public func configCredential(_ accessKeyId: String, _ accessKeySecrect: String, _ securityToken: String, _ completion: AliOSSHandlerConfigCompletion?) {
        
        checkServerParams()
        guard !accessKeyId.isEmpty, !accessKeySecrect.isEmpty, !securityToken.isEmpty else {
            let error = GCAliOSSError.ServerAccessConfig(accessKeyId: accessKeyId, accessKeySecrect: accessKeySecrect, securityToken: securityToken)
            completion?(GCAliOSSError.accessConfigError(.serverAccessConfigInvalid(error: error)))
            return
        }
        
        DispatchQueue.global().async { [weak self] in
          
            guard let self = self, let config = self.config else {
                completion?(.accessConfigError(.instanceIsCollected))
                return
            }
            
            let credential = OSSFederationCredentialProvider { [weak self] in // 防止杀进程时单例销毁导致崩溃
                
                guard let self = self, let config = self.config, let url = URL(string: config.oss_sts_server) else {
                    return OSSFederationToken()
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let tcs = OSSTaskCompletionSource<NSData>()
                let session = URLSession.shared
                // 发送请求。
                let _ = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        tcs.setError(error)
                        return
                    }
                    tcs.setResult(data as? NSData)
                }.resume()
                // 需要阻塞等待请求返回。
                tcs.task.waitUntilFinished()
                // 解析结果。
                if let _ = tcs.task.error {
                    return OSSFederationToken()
                } else {
                    // 返回数据为JSON格式，需要解析返回数据得到token的各个字段。
                    if let returnData = tcs.task.result as? Data,
                       let dataDic = try? JSONSerialization.jsonObject(with: returnData) as? [String : Any],
                       let data = dataDic?["data"] as? [String : Any], // 奇怪的编译器要可选访问dataDic
                       let accessKeyId = data["AccessKeyId"] as? String,
                       let accessKeySecret = data["AccessKeySecret"] as? String,
                       let securityToken = data["SecurityToken"] as? String,
                       let expiration = data["Expiration"] as? String {
                        let token = OSSFederationToken()
                        token.tAccessKey = accessKeyId
                        token.tSecretKey = accessKeySecret
                        token.tToken = securityToken
                        token.expirationTimeInGMTFormat = expiration
                        return token
                    } else {
                        return OSSFederationToken()
                    }
                }
            }
            let token = OSSFederationToken()
            token.tAccessKey = accessKeyId
            token.tSecretKey = accessKeySecrect
            token.tToken = securityToken
            credential.cachedToken = token
            let conf = OSSClientConfiguration()
            // 网络请求遇到异常失败后的重试次数
            conf.maxRetryCount = 3
            // 网络请求的超时时间
            conf.timeoutIntervalForRequest = 60.0
            // 允许资源传输的最长时间
            conf.timeoutIntervalForResource = 24 * 60 * 60
            self._ossClient = OSSClient(endpoint: config.oss_end_point, credentialProvider: credential, clientConfiguration: conf)
            
            completion?(nil)
        }
    }
    /// 上传数据
    /// - Parameters:
    ///   - data: 文件数据
    ///   - uploadProgress: 上传进度回调
    ///   - uploadCompletion: 上传完成回调
    public func uploadData(data: GCAliOSSUploadData, uploadCompletion: AliOSSHandlerUploadCompletion?) {
        
        checkServerParams()
        guard let client = _ossClient, let config = self.config else {
            uploadCompletion?("", .unInit)
            return
        }
        
        let put = OSSPutObjectRequest()
        put.bucketName = config.ossbucket_name
        let filePath = config.oss_file_prefix.appending(data.fileName)
        put.objectKey = filePath
        put.uploadingData = data.fileData
        if let uploadProgress = data.uploadTraceCallback {
            put.uploadProgress = uploadProgress
        }
        
        let putTask = client.putObject(put)
        putTask.continue ({ task in
            var completionPath = ""
            if let error = task.error {
                uploadCompletion?(completionPath, .uploadError(error: error))
            } else {
                completionPath = config.oss_server_prefix + "/" + filePath
                uploadCompletion?(completionPath, nil)
            }
            return nil
        })
    }
    
    /// 上传多个数据
    /// - Parameters:
    ///   - datas: 数据数组
    ///   - uploadCompletion: 完成回调
    public func uploadDatas(datas: [GCAliOSSUploadData], uploadCompletion: AliOSSHandlerUploadFilesCompletion?) {
        
        guard !datas.isEmpty else {
            uploadCompletion?([], .emptyDataError)
            return
        }
        
        var completionPaths = [String]()
        completionPaths.reserveCapacity(datas.count)
        let group = DispatchGroup()
        var uploadError: Error?
        
        for data in datas {
            group.enter()
            uploadData(data: data) { urlPath, error in
                completionPaths.append(urlPath)
                if let error = error {
                    uploadError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = uploadError {
                uploadCompletion?(completionPaths, .uploadError(error: error))
            } else {
                uploadCompletion?(completionPaths, nil)
            }
        }        
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - file: 文件模型
    ///   - uploadCompletion: 上传完成回调
    public func uploadFile(file: GCAliOSSUploadFile, uploadCompletion: AliOSSHandlerUploadCompletion?) {
        
        checkServerParams()
        guard let client = _ossClient, let config = self.config else {
            uploadCompletion?("", .unInit)
            return
        }
        
        let put = OSSPutObjectRequest()
        put.bucketName = config.ossbucket_name
        let saveKey = config.oss_file_prefix + file.fileKey
        put.objectKey = saveKey
        put.uploadingFileURL = file.fileUrl
        if let uploadProgress = file.uploadTraceCallback {
            put.uploadProgress = uploadProgress
        }
        let putTask = client.putObject(put)
        putTask.continue ({ task in
            var completionPath = ""
            if let error = task.error {
                uploadCompletion?(completionPath, .uploadError(error: error))
            } else {
                completionPath = config.oss_server_prefix + saveKey
                uploadCompletion?(completionPath, nil)
            }
            return nil
        })
    }
    
    /// 上传多个文件
    /// - Parameters:
    ///   - files: 文件模型数组
    ///   - uploadCompletion: 上传完成回调
    public func uploadFiles(files: [GCAliOSSUploadFile], uploadCompletion: AliOSSHandlerUploadFilesCompletion?) {
        
        guard !files.isEmpty else {
            uploadCompletion?([], .emptyFileError)
            return
        }
        
        var completionPaths = [String]()
        completionPaths.reserveCapacity(files.count)
        let group = DispatchGroup()
        var uploadError: Error?
        
        for file in files {
            group.enter()
            uploadFile(file: file) { urlPath, error in
                completionPaths.append(urlPath)
                if let error = error {
                    uploadError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = uploadError {
                uploadCompletion?(completionPaths, .uploadError(error: error))
            } else {
                uploadCompletion?(completionPaths, nil)
            }
        }
    }
    
    /// 重置服务
    public func reset() {
        _config = nil
        _ossClient = nil
    }
}
