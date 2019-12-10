//
//  URLs.swift
//  ForaBank
//
//  Created by Бойко Владимир on 20/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

enum ServerType {
    case test
    case production
}

var serverType: ServerType = ServerType.test
public var apiBaseURL: String {
    switch serverType {
    case .test:
        return testApiBaseURL
    case .production:
        return productionApiBaseURL
    }
}

let testApiBaseURL: String = "https://git.briginvest.ru/dbo/api/v2/"
let productionApiBaseURL: String = "https://git.briginvest.ru/dbo/api/v2/"
