//
//  GCAWSS3Serialization.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/3/6.
//

import Foundation

class GCAWSS3Serialization: JSONSerialization {
    
    override class func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        
        if let dataDic = try super.jsonObject(with: data, options: opt) as? [String : Any],
           let dataArray = dataDic["data"] as? [String : [[String : Any]]],
           let results = dataArray["preUrlResults"] {
            return results
        }
        throw GCAWSS3Error.preUploadError(.serverReturnParamError)
    }
}

