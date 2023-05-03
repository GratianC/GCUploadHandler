//
//  GCAWSS3Param.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/24.
//

import Foundation

/// AWSS3上传配置
public struct GCAWSS3HandlerConfig {
    
    /// 预上传请求URLRequest
    public private(set) var preUrlRequest: URLRequest
    /// 默认上传文件夹
    public private(set) var defaultFoGCer: String
    /// 适配器
    public private(set) var adapter: AWSS3RequestAdapter?
    
    public init(preUrlRequest: URLRequest, defaultFoGCer: String, adapter: AWSS3RequestAdapter? = nil) {
        self.preUrlRequest = preUrlRequest
        self.defaultFoGCer = defaultFoGCer
        self.adapter = adapter
    }
}

public struct GCAWSS3UploadData {
    
    /// 图片数据
    public private(set) var fileData: Data
    /// 图片名称
    public private(set) var fileName: String
    
    public init(fileData: Data, fileName: String) {
        self.fileData = fileData
        self.fileName = fileName
    }
}

public struct GCAWSS3UploadFile {
    
    /// 图片数据
    public private(set) var fileUrl: URL
    /// 图片名称
    public private(set) var fileName: String
    
    public init(fileUrl: URL, fileName: String) {
        self.fileUrl = fileUrl
        self.fileName = fileName
    }
}

/// 文件上传位置结构体
struct GCAWSS3PreUrlResults {
    
    /// 上传完成文件服务器URL
    var key: String
    /// 上传URL
    var url: String
    
    static func results(by array: Any) -> [GCAWSS3PreUrlResults]? {
        
        if let next = array as? [[String : Any]] {
           return next.map { dic in
                if let key = dic["key"] as? String, let url = dic["url"] as? String {
                    return GCAWSS3PreUrlResults(key: key, url: url)
                }
                return GCAWSS3PreUrlResults(key: "", url: "")
            }
        }
        return nil
    }
}
