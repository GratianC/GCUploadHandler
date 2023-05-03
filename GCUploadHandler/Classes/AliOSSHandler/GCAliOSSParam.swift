//
//  GCAliOSSParam.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/27.
//

import Foundation

private protocol GCAliOSSParamCheck {
    
    /// 检查模型参数
    func checkParams()
}

/// 阿里云上传进度回调协议
public protocol GCAliOSSParamUploadTraceble {
   
    typealias AliOSSHandlerUploadProgress = (_ byteSent: Int64, _ totalByteSent: Int64, _ totalBytesExpectedToSend: Int64) -> Void
    
    /// 阿里云上传进度回调
    var uploadTraceCallback: AliOSSHandlerUploadProgress? { get }
}

/// 阿里云上传服务配置
public struct GCAliOSSConfig: GCAliOSSParamCheck {
    
    /// EndPoint
    public private(set) var oss_end_point: String
    /// bucketName 名称
    public private(set) var ossbucket_name: String
    /// STS 验证服务器
    public private(set) var oss_sts_server: String
    /// 文件夹名称
    public private(set) var oss_file_prefix: String
    /// 服务器文件地址前缀
    public private(set) var oss_server_prefix: String
    
    public init(oss_end_point: String, ossbucket_name: String, oss_sts_server: String, oss_file_prefix: String, oss_server_prefix: String) {
        self.oss_end_point = oss_end_point
        self.ossbucket_name = ossbucket_name
        self.oss_sts_server = oss_sts_server
        self.oss_file_prefix = oss_file_prefix
        self.oss_server_prefix = oss_server_prefix
        
        checkParams()
    }
    
    /// 检查配置参数
    func checkParams() {
        
        assert(!oss_end_point.isEmpty, "OSSENDPOINT Can't Be Empty")
        assert(!ossbucket_name.isEmpty, "OSSBUCKETNAME Can't Be Empty")
        assert(!oss_sts_server.isEmpty, "OSSSTSSERVER Can't Be Empty")
        assert(!oss_file_prefix.isEmpty, "OSSFILEPREFIX Can't Be Empty")
        assert(!oss_server_prefix.isEmpty, "OSSERVERFIX Can't Be Empty")
    }
}

public struct GCAliOSSUploadData: GCAliOSSParamCheck & GCAliOSSParamUploadTraceble {
    
    /// 图片数据
    public private(set) var fileData: Data
    /// 图片名称
    public private(set) var fileName: String
    /// 上传回调
    public var uploadTraceCallback: AliOSSHandlerUploadProgress?
    
    public init(fileData: Data, fileName: String, uploadTraceCallback: AliOSSHandlerUploadProgress? = nil) {
        self.fileData = fileData
        self.fileName = fileName
        self.uploadTraceCallback = uploadTraceCallback
        
        checkParams()
    }
    
    /// 检查配置参数
    func checkParams() {
        
        assert(fileData.count > 0, "FileData Can't Be Empty")
        assert(!fileName.isEmpty, "FileName Can't Be Empty")
    }
}

public struct GCAliOSSUploadFile: GCAliOSSParamCheck & GCAliOSSParamUploadTraceble {
    
    /// 文件地址
    public private(set) var fileUrl: URL
    /// 文件名称
    public private(set) var fileKey: String
    /// 上传回调
    public var uploadTraceCallback: AliOSSHandlerUploadProgress?
    
    public init(fileUrl: URL, fileKey: String, uploadTraceCallback: AliOSSHandlerUploadProgress? = nil) {
        self.fileUrl = fileUrl
        self.fileKey = fileKey
        self.uploadTraceCallback = uploadTraceCallback
        
        checkParams()
    }
    
    /// 检查配置参数
    func checkParams() {
        
        assert(!fileUrl.absoluteString.isEmpty, "FileUrl Can't Be Empty")
        assert(!fileKey.isEmpty, "FileKey Can't Be Empty")
    }
}
