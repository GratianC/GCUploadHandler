//
//  GCAWSS3Adapter.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/3/10.
//

import Foundation

public protocol AWSS3RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) -> URLRequest
}

extension AWSS3RequestAdapter {
    
    public func adapt(_ urlRequest: URLRequest) -> URLRequest {
        urlRequest
    }
}

public struct GCAWSS3Adapter: AWSS3RequestAdapter {
    
    /// Default adapter for awss service
    static let `default`: AWSS3RequestAdapter = GCAWSS3Adapter()
}
