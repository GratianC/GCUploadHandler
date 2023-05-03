//
//  GCAliOSSPresenter.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/27.
//

import UIKit

class GCAliOSSPresenter {
    
    /// 配置阿里云
    /// - Parameters:
    ///   - targetId: 用户id
    ///   - completion: 完成回调
    ///   - failed: 失败回调
    func aliConfig(_ urlString: String, completion: (([String : Any]?) -> Void)?, failed: (([String : Any]?) -> Void)?) {
        
        if let next = URL(string: urlString) {
            URLSession.shared.dataTask(with: next) { data, response, error in
                if let data = data, let dataDic = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String : Any] {
                    completion?(dataDic)
                } else {
                    failed?(nil)
                }
            }.resume()
        }
    }
}
