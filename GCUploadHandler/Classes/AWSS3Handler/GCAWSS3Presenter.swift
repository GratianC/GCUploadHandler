//
//  GCAWSS3Presenter.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/3/6.
//

import Foundation

/// 文件上传地址请求参数
private struct _GCAWSS3PreUploadParams {
    
     struct GCAWSS3PreUploadParam: Encodable {
        /// 上传文件名
        var fileName: String
        /// 上传目标文件夹
        var foGCer: String
        
        enum CodingKeys: CodingKey {
            case fileName
            case foGCer
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.fileName, forKey: .fileName)
            try container.encode(self.foGCer, forKey: .foGCer)
        }
    }
    /// 参数数组
    private var _paramArray: [GCAWSS3PreUploadParam] = []

    @discardableResult
    mutating func appendParam(_ param: GCAWSS3PreUploadParam) -> _GCAWSS3PreUploadParams {
        _paramArray.append(param)
        return self
    }
    
    @discardableResult
    mutating func appendParam(_ params: [GCAWSS3PreUploadParam]) -> _GCAWSS3PreUploadParams {
        _paramArray.append(contentsOf: params)
        return self
    }
    
    var requestDic: [String : [GCAWSS3PreUploadParam]] {
        ["preUploadParams" : _paramArray]
    }
}

/// 文件上传请求
struct GCAWSS3Presenter {
    
    /// 请求
    private var _preUrlRequest: URLRequest?
    var preUrlRequest: URLRequest? {
        get {
            _preUrlRequest
        }
        set {
            _preUrlRequest = newValue
        }
    }
    /// 是否服务可用
    var isUseful: Bool {
        preUrlRequest != nil
    }
    ///
    private var _adapter = GCAWSS3Adapter.default
    var adapter: AWSS3RequestAdapter? {
        get {
            _adapter
        }
        set {
            if let newValue = newValue {
                _adapter = newValue
            }
        }
    }
    
    /// Encoder which encode parampeters
    private let _encoder = GCAWSS3Encoder.default
    
    ///  RequestQueue
    private let _requestQueue = DispatchQueue(label: "com.awss3.upload.module.request.queue", qos: .userInteractive)
    /// Quick URLRequest for upload
    private func uploadRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("binary", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// 重置
    mutating func reset() {
        preUrlRequest = nil
        _adapter = GCAWSS3Adapter.default
    }
    
    /// 获取文件上传路径
    private func requestUploadConfig(pre: _GCAWSS3PreUploadParams, completion: @escaping (([GCAWSS3PreUrlResults]?, GCAWSS3Error?) -> Void)) throws  {
        
        @Sendable func preRequest(_ request: URLRequest) {
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    do {
                        let results = try GCAWSS3Serialization.jsonObject(with: data, options: [.fragmentsAllowed])
                        completion(GCAWSS3PreUrlResults.results(by: results), nil)
                    }
                    catch {
                        completion(nil, error as? GCAWSS3Error ?? .preUploadError(.serverReturnParamError))
                    }
                } else {
                    completion(nil, .preUploadError(.serverRequestError))
                }
             }).resume()
        }
        
        guard let preRe = _preUrlRequest else {
            completion(nil, .unconfigured)
            return
        }
        let request = try _encoder.encode(pre.requestDic, into: preRe)
        let adaptRequest = _adapter.adapt(request)
        
        if #available(iOS 13.0, *) {
            @Sendable func asyncPreRequest(_ request: URLRequest) async {
                preRequest(request)
            }
             Task {
                await asyncPreRequest(adaptRequest)
            }
        } else {
            _requestQueue.async  {
                preRequest(adaptRequest)
            }
        }
    }
    
    /// 上传数据到AWSS3
    /// - Parameters:
    ///   - data: 上传Data
    ///   - foGCer: 目标文件夹
    ///   - completion: 完成回调
    func uploadData(datas: [GCAWSS3UploadData], foGCer: String, completion: (([String], GCAWSS3Error?) -> Void)?) {
        
        // 主线程错误回调
        func disposeError(_ error: GCAWSS3Error) {
            DispatchQueue.main.async {
                completion?([], error)
            }
        }
        
        var params = _GCAWSS3PreUploadParams()
        params.appendParam(datas.map({ data in
            _GCAWSS3PreUploadParams.GCAWSS3PreUploadParam(fileName: data.fileName, foGCer: foGCer)
        }))
        do {
            try requestUploadConfig(pre: params) { results, error in
                if let error = error {
                    disposeError(error)
                    return
                }
                if let results = results {
                    uploadData(datas: (datas, results), completion: completion)
                }
            }
        } catch {
            disposeError(error as? GCAWSS3Error ?? .preUploadError(.preUploadError))
        }
    }
    
    /// 上传Data到AWSS3
    /// - Parameters:
    ///   - data: (被上传Data, Data对应上传路径)
    ///   - completion: 完成回调
    func uploadData(datas: ([GCAWSS3UploadData], [GCAWSS3PreUrlResults]), completion: (([String], GCAWSS3Error?) -> Void)?) {
        
        if datas.0.count != datas.1.count {
            completion?([], GCAWSS3Error.preUploadError(.serverReturnParamError))
            return
        }
        
        let group = DispatchGroup()
        var uploadError: Error?
        var uploadPaths: [String] = []
        for i in 0...datas.0.count - 1 {
            let dataS = datas.0[i]
            let urlS = datas.1[i]
            if let url = URL(string: urlS.url) {
                group.enter()
                let request = uploadRequest(url: url)
                URLSession.shared.uploadTask(with: request, from: dataS.fileData) { data, response, error in
                    if let error = error {
                        uploadError = error
                    } else {
                        uploadPaths.append(urlS.key)
                    }
                    group.leave()
                }.resume()
            }
        }
        
        group.notify(queue: .main) {
            if let _ = uploadError {
                completion?(uploadPaths, GCAWSS3Error.uploadOccuredError)
            } else {
                completion?(uploadPaths, nil)
            }
        }
    }
    
    /// 上传文件到AWSS3
    /// - Parameters:
    ///   - files: 上传Files
    ///   - foGCer: 目标文件夹
    ///   - completion: 完成回调
    func uploadFile(files: [GCAWSS3UploadFile], foGCer: String, completion: (([String], GCAWSS3Error?) -> Void)?) {
        
        // 主线程错误回调
        func disposeError(_ error: GCAWSS3Error) {
            DispatchQueue.main.async {
                completion?([], error)
            }
        }
        
        var params = _GCAWSS3PreUploadParams()
        params.appendParam(files.map({ file in
            _GCAWSS3PreUploadParams.GCAWSS3PreUploadParam(fileName: file.fileName, foGCer: foGCer)
        }))
        do {
            try requestUploadConfig(pre: params) { results, error in
                if let error = error {
                    disposeError(error)
                    return
                }
                if let results = results {
                    uploadFile(files: (files, results), completion: completion)
                }
            }
        } catch {
            disposeError(error as? GCAWSS3Error ?? .preUploadError(.preUploadError))
        }
    }
    
    /// 上传Data到AWSS3
    /// - Parameters:
    ///   - files: (被上传Data, Data对应上传路径)
    ///   - completion: 完成回调
    func uploadFile(files: ([GCAWSS3UploadFile], [GCAWSS3PreUrlResults]), completion: (([String], GCAWSS3Error?) -> Void)?) {
        
        if files.0.count != files.1.count {
            completion?([], GCAWSS3Error.preUploadError(.serverReturnParamError))
            return
        }
        
        let group = DispatchGroup()
        var uploadError: Error?
        var uploadPaths: [String] = []
        for i in 0...files.0.count - 1 {
            let fileS = files.0[i]
            let urlS = files.1[i]
            if let url = URL(string: urlS.url) {
                group.enter()
                let request = uploadRequest(url: url)
                URLSession.shared.uploadTask(with: request, fromFile: fileS.fileUrl) { data, response, error in
                    if let error = error {
                        uploadError = error
                    } else {
                        uploadPaths.append(urlS.key)
                    }
                    group.leave()
                }.resume()
            }
        }
        
        group.notify(queue: .main) {
            if let _ = uploadError {
                completion?(uploadPaths, GCAWSS3Error.uploadOccuredError)
            } else {
                completion?(uploadPaths, nil)
            }
        }
    }
}
