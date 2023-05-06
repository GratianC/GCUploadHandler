//
//  GCUploadParam.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/24.
//

import Foundation

/// 阿里云初始化回调
public typealias UploadHandlerAliOSSHandlerConfigCompletion = (_ error: Error?) -> Void
/// 亚马逊云适配器
public typealias UploadHandlerAWSS3Adapter =  AWSS3RequestAdapter

/// 上传初始化配置
public struct GCUploadHandlerConfig {
        
    // MARK: AliOSS
    public private(set) var aliOSSConfig: GCUploadHandlerAliOSSConfig
    public private(set) var aliOSSInitCompletion: UploadHandlerAliOSSHandlerConfigCompletion?
    // MARK: AWSS3
    public private(set) var awss3Config: GCUploadHandlerAWSS3HandlerConfig
    
    public init(aliOSSConfig: GCUploadHandlerAliOSSConfig, aliOSSInitCompletion: UploadHandlerAliOSSHandlerConfigCompletion? = nil, awss3Config: GCUploadHandlerAWSS3HandlerConfig) {
        self.aliOSSConfig = aliOSSConfig
        self.aliOSSInitCompletion = aliOSSInitCompletion
        self.awss3Config = awss3Config
    }
}
/// 阿里云上传服务配置
public struct GCUploadHandlerAliOSSConfig {
    
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

    }
    
    /// 适配阿里云配置接口
    var aliossConfig: GCAliOSSConfig {
         GCAliOSSConfig(oss_end_point: oss_end_point, ossbucket_name: ossbucket_name, oss_sts_server: oss_sts_server, oss_file_prefix: oss_file_prefix, oss_server_prefix: oss_server_prefix)
    }
}

/// AWSS3上传配置
public struct GCUploadHandlerAWSS3HandlerConfig {
    
    /// 预上传请求URLRequest
    public private(set) var preUrlRequest: URLRequest
    /// 默认上传文件夹
    public private(set) var defaultfolder: String
    /// 预上传适配器
    public private(set) var adapter: UploadHandlerAWSS3Adapter?
    
    public init(preUrlRequest: URLRequest, defaultfolder: String, adapter: UploadHandlerAWSS3Adapter? = nil) {
        self.preUrlRequest = preUrlRequest
        self.defaultfolder = defaultfolder
        self.adapter = adapter
    }
    
    /// 适配亚马逊云配置接口
    var awss3Config: GCAWSS3HandlerConfig {
        GCAWSS3HandlerConfig(preUrlRequest: preUrlRequest, defaultfolder: defaultfolder, adapter: adapter)
    }
}


public struct GCUploadHandlerUploadData {
    
    /// 图片数据
    public private(set) var fileData: Data
    /// 图片名称
    public private(set) var fileName: String
    
    public init(fileData: Data, fileName: String) {
        self.fileData = fileData
        self.fileName = fileName
    }
}

public struct GCUploadHandlerFile {
    
    /// 图片数据
    public private(set) var fileUrl: URL
    /// 图片名称
    public private(set) var fileName: String
    
    public init(fileUrl: URL, fileName: String) {
        self.fileUrl = fileUrl
        self.fileName = fileName
    }
}
