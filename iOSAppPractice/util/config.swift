//
//  config.swift
//  iOSAppPractice
//
//  Created by Carter on 2018/3/29.
//  Copyright © 2018年 Carter. All rights reserved.
//

import Foundation

enum APIConfig {
    static let baseURL = "http://data.taipei"
    static let limit = "30"
    static let scope = "resourceAquire"
}

extension APIConfig {
    static var queryURL: String {
        return APIConfig.baseURL.appending("/opendata/datalist/apiAccess")
    }
}

enum AlertConfig {
    static let title = "訊息"
    static let confirm = "確定"
}

enum ReUseIdentifier {
    static let spot = String(describing: SpotTableViewCell.self)
}

