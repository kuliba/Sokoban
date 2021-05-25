//
//  LivetexCoreManager.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 29.04.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import LivetexCore


let kApplicationDidReceiveNetworkStatus = "kApplicationDidReceiveNetworkStatus"
let kApplicationDidRegisterWithDeviceToken = "kApplicationDidRegisterWithDeviceToken"

private var URL:String? = "https://authentication-service-sdk-production-1.livetex.ru"
var key:String? =  "demo"
var siteID:String? = "166171"

class LivetexCoreManager {
    static let defaultManager: LivetexCoreManager = LivetexCoreManager()
    
    var coreService: LCCoreService!
    var apnToken: String?
    var messageService: LCMessage!
}
