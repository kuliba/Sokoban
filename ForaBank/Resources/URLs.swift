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

class Host {

    static let shared: Host = Host()

    public var serverType: ServerType = ServerType.test
    public var apiBaseURL: String {
        switch serverType {
        case .test:
            return testApiBaseURL
        case .production:
            return productionApiBaseURL
        }
    }

    private let testApiBaseURL: String = "https://git.briginvest.ru/dbo/api/v2/"
    private let productionApiBaseURL: String = "https://bg.forabank.ru/dbo/api/v3/f437e29a3a094bcfa73cea12366de95b/"
    

}
