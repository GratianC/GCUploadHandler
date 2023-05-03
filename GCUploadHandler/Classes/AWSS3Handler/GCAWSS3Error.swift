//
//  GCAWSS3Error.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/3/6.
//

import Foundation

public enum GCAWSS3Error: Error {
    
    public enum PreUploadError {
        // 服务器请求出错
        case serverRequestError
        // 服务器返回参数错误
        case serverReturnParamError
        // 预上传过程出现错误
        case preUploadError
        
    }
    
    // 未进行配置
    case unconfigured
    // 参数错误
    case paramError
    // 参数序列化错误
    case parameterEncodingFailed
    // 上传出现错误
    case uploadOccuredError
    // 预上传错误
    case preUploadError(PreUploadError)
}
