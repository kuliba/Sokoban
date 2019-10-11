//
//  BaseRequest.swift
//  Anna
//
//  Created by Igor on 25/09/2017.
//  Copyright © 2017 Anna Financial Service Ltd. All rights reserved.
//

import UIKit
import Alamofire

class BaseRequest {
//    let apiUrlString = ApiConstant.apiUrl
    let customerPath = "/customer"
    let authHeader = "Authorization"
    let bearerKey = "Bearer "
    let osName = "ios"

    var transport = NetworkTransport()
    
    init() {}

    final func headers(withToken token: String) -> [String: String] {
        return [authHeader: "\(bearerKey)\(token)"]
    }
}
