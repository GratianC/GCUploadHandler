//
//  GCAliOSSError.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/27.
//

import Foundation

public enum GCAliOSSError: Error {
    
    /// 后台配置错误
    public enum AccessConfigErrorReason {
        // 后台配置请求错误
        case requestFailure(urlString: String)
        // 后台配置返回错误
        case serverAccessConfigInvalid(error: Error)
        // 对象已释放
        case instanceIsCollected
    }
    
    /// 后台返回配置错误原因
    public struct ServerAccessConfig: Error {
        /// 后台返回AccessKeyId
        public private(set) var accessKeyId: String
        /// 后台返回AccessKeySecrect
        public private(set) var accessKeySecrect: String
        /// 后台返回SecurityToken
        public private(set) var securityToken: String
    }
    
    // 未初始化上传服务
    case unInit
    // 后台配置错误
    case accessConfigError(AccessConfigErrorReason)
    // 阿里云上传失败
    case uploadError(error: Error)
    // 空数据上传错误
    case emptyDataError
    // 空文件上传错误
    case emptyFileError
}

extension GCAliOSSError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .unInit:
            return "Server UnInit"
        case let .accessConfigError(reason):
            return reason.localizedDescription
        case let .uploadError(error):
            return "AliOSS upload file error: \(error.localizedDescription)"
        case .emptyDataError:
            return "Empty data pass in error"
        case .emptyFileError:
            return "Empty file pass in error"
        }
    }
}

extension GCAliOSSError.AccessConfigErrorReason {
    
    var underlyingError: Error? {
        switch self {
        case let .serverAccessConfigInvalid(error):
            return error
        default:
            return nil
        }
    }
    
    var localizedDescription: String {
        switch self {
        case let .serverAccessConfigInvalid(error):
            return "Server config return error: \(error)"
        case let .requestFailure(urlString):
            return "Server config request failed: \(urlString)"
        case .instanceIsCollected:
            return "Instance is collected can't be used again"
        }
    }
}

extension Error {
    
    /// Returns the instance cast as an `GCAliOSSError`.
    public var asGCAliOSSError: GCAliOSSError? {
        self as? GCAliOSSError
    }
    
    /// Returns the instance cast as an `AFError`. If casting fails, a `fatalError` with the specified `message` is thrown.
    public func asGCAliOSSError(orFailWith message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> GCAliOSSError {
        guard let gcError = self as? GCAliOSSError else {
            fatalError(message(), file: file, line: line)
        }
        return gcError
    }
    
    /// Casts the instance as `GCAliOSSError` or returns `defaultAFError`
    func asGCAliOSSError(or defaultAFError: @autoclosure () -> GCAliOSSError) -> GCAliOSSError {
        self as? GCAliOSSError ?? defaultAFError()
    }
}
