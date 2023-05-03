//
//  GCAWSS3Handler.swift
//  GCUploadKit
//
//  Created by GratianC on 2023/2/23.
//

import Foundation
import Dispatch

/// 亚马逊云上传文件完成回调
public typealias AWSS3UploadCompleted = (_ urlPath: [String], _ error: GCAWSS3Error?) -> Void

public class GCAWSS3Handler {
    
    /// 单例
    public static let share = GCAWSS3Handler()
    private init() {
    }

    /// 数据请求
    private var _presenter = GCAWSS3Presenter()
    /// 默认文件夹
    private var _defaultFoGCer = ""

    /// 初始化亚马逊云服务
    /// - Parameters:
    ///   - accessKey: 访问ID
    ///   - secretKey: 访问密钥
    public func configAWSS3Service(with config: GCAWSS3HandlerConfig) {
        
        _presenter.preUrlRequest = config.preUrlRequest
        _presenter.adapter = config.adapter
        _defaultFoGCer = config.defaultFoGCer
    }
    
    /// 重置亚马逊云服务
    public func resetAWSS3Service() {
        _presenter.reset()
    }
    
    private func checkServerUseful() {
        assert(_presenter.isUseful, "Config server param at first")
    }
    
    /// 图片上传
    /// - Parameters:
    ///   - data: UploadData
    ///   - foGCer: Target file foGCer
    ///   - completed: Upload complete callback
    public func uploadData(_ data: [GCAWSS3UploadData], foGCer: String = "", completed: AWSS3UploadCompleted?) {
        
        checkServerUseful()
        let uploadFoGCer = foGCer.isEmpty ? _defaultFoGCer : foGCer
        _presenter.uploadData(datas: data, foGCer: uploadFoGCer, completion: completed)
    }
    
    /// 文件上传
    /// - Parameters:
    ///   - file: UploadFile
    ///   - foGCer: Target file foGCer
    ///   - completed: Upload complete callback
    public func uploadFile(_ file: [GCAWSS3UploadFile], foGCer: String = "", completed: AWSS3UploadCompleted?) {
        
        checkServerUseful()
        let uploadFoGCer = foGCer.isEmpty ? _defaultFoGCer : foGCer
        _presenter.uploadFile(files: file, foGCer: uploadFoGCer, completion: completed)
    }
}
