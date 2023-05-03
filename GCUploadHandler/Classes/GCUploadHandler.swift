//
//  GCUploadHandler.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/24.
//

import Foundation

/// 上传进度回调
public typealias UploadHandlerProgressOperaion = (_ progress: Progress) -> Void
/// 上传文件完成回调
public typealias UploadHandlerUploadFileCompletion = (_ urlPath: String, _ error: Error?) -> Void
/// 上传多个文件完成回调
public typealias UploadHandlerUploadFilesCompletion = (_ urlPath: [String], _ error: Error?) -> Void

public class GCUploadHandler {
    
    /// 单例
    public static let shared = GCUploadHandler()
    private init() {
    }
    /// 是否开启国内加速
    private var _isAccelerated = false
    public var isAccelerated: Bool {
        get {
            _isAccelerated
        }
        set {
            _isAccelerated = newValue
        }
    }
    /// AWSS3
    private let _awss = GCAWSS3Handler.share
    /// AliOSS
    private let _alioss = GCAliOSSHandler.shared
    
    /// 初始化上传管理
    public func initUploadHandler(isAccelerated: Bool, config: GCUploadHandlerConfig) {
        
        _isAccelerated = isAccelerated
        configAWSS3(config.awss3Config)
        configAliOSS(config.aliOSSConfig, completion: config.aliOSSInitCompletion)
    }
    
    /// 配置亚马逊云
    public func configAWSS3(_ config: GCUploadHandlerAWSS3HandlerConfig ) {
        
        _awss.configAWSS3Service(with: config.awss3Config)
    }
    
    /// 配置阿里云
    public func configAliOSS(_ config: GCUploadHandlerAliOSSConfig, completion: UploadHandlerAliOSSHandlerConfigCompletion?) {
        _alioss.config(config: config.aliossConfig, completion: completion)
    }
    
    /// 重置上传服务
    public func reset() {
        
        _isAccelerated = false
        _alioss.reset()
        _awss.resetAWSS3Service()
    }
    
    /// 上传数据
    /// - Parameters:
    ///   - data: 数据
    ///   - uploadCompletion: 上传完成回调
    public func uploadData(data: GCUploadHandlerUploadData, uploadCompletion: UploadHandlerUploadFileCompletion?) {
        
        if _isAccelerated {
            _alioss.uploadData(data: GCAliOSSUploadData(fileData: data.fileData, fileName: data.fileName), uploadCompletion: uploadCompletion)
        } else {
            _awss.uploadData([GCAWSS3UploadData(fileData: data.fileData, fileName:data.fileName)]) { urlPath, error in
                uploadCompletion?(urlPath.first ?? "", error)
            }
        }
    }
    
    /// 上传多个数据
    /// - Parameters:
    ///   - datas: 数据
    ///   - uploadCompletion: 上传完成回调
    public func uploadDatas(datas: [GCUploadHandlerUploadData], uploadCompletion: UploadHandlerUploadFilesCompletion?) {
        
        if _isAccelerated {
            _alioss.uploadDatas(datas: datas.map({ data in
                GCAliOSSUploadData(fileData: data.fileData, fileName: data.fileName)
            }), uploadCompletion: uploadCompletion)
        } else {
            _awss.uploadData(datas.map({ data in
                GCAWSS3UploadData(fileData: data.fileData, fileName: data.fileName)
            }), completed: uploadCompletion)
        }
    }

    /// 上传沙盒文件
    /// - Parameters:
    ///   - file: 上传文件
    ///   - uploadCompletion: 上传完成回调
    public func uploadFile(file: GCUploadHandlerFile, uploadCompletion: UploadHandlerUploadFileCompletion?) {
        
        if _isAccelerated {
            _alioss.uploadFile(file: GCAliOSSUploadFile(fileUrl: file.fileUrl, fileKey: file.fileName), uploadCompletion: uploadCompletion)
        } else {
            _awss.uploadFile([GCAWSS3UploadFile(fileUrl: file.fileUrl, fileName: file.fileName)]) { urlPath, error in
                uploadCompletion?(urlPath.first ?? "", error)
            }
        }
    }
 
    /// 上传多个沙盒文件
    /// - Parameters:
    ///   - files: 上传文件
    ///   - uploadCompletion: 上传完成回调
    public func uploadFiles(files: [GCUploadHandlerFile], uploadCompletion: UploadHandlerUploadFilesCompletion?) {
        
        if _isAccelerated {
            _alioss.uploadFiles(files: files.map({ file in
                GCAliOSSUploadFile(fileUrl: file.fileUrl, fileKey: file.fileName)
            }), uploadCompletion: uploadCompletion)
        } else {
            _awss.uploadFile(files.map({ file in
                GCAWSS3UploadFile(fileUrl: file.fileUrl, fileName: file.fileName)
            }), completed: uploadCompletion)
        }
    }
    
    /// 上传文件至亚马逊云目标文件夹
    public func uploadToAWSS(files: [GCUploadHandlerFile], foGCer: String = "", uploadCompletion: UploadHandlerUploadFilesCompletion?) {
        
        _awss.uploadFile(files.map({ file in
            GCAWSS3UploadFile(fileUrl: file.fileUrl, fileName: file.fileName)
        }), completed: uploadCompletion)
    }
}
