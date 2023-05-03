//
//  GCAWSS3Encoder.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/3/6.
//

import Foundation

public protocol ParameterEncoder {
    
    /// Encode the provided `Encodable` parameters into `request`.
    func encode<Parameters: Encodable>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest
}

struct GCAWSS3Encoder: ParameterEncoder {
    
    /// Returns an encoder with default parameters.
    static var `default`: GCAWSS3Encoder { GCAWSS3Encoder() }
    
    private let _encoder: JSONEncoder
    init(_encoder: JSONEncoder = JSONEncoder()) {
        self._encoder = _encoder
    }
    
    func encode<Parameters>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest where Parameters : Encodable {
        
        guard let parameters = parameters else { return request }
        
        var request = request
        
        do {
            let data = try _encoder.encode(parameters)
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            throw GCAWSS3Error.parameterEncodingFailed
        }
        
        return request
    }
}
