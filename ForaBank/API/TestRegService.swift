//
//  TestRegService.swift
//  ForaBank
//
//  Created by Sergey on 12/01/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class TestRegService: RegServiceProtocol {
    
    func checkClient(headers: HTTPHeaders,
                     cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
        completionHandler(true, nil)
    }
    
    func doRegistration(headers: HTTPHeaders, completionHandler: @escaping (Bool, String?, String?, String?) -> Void) {
        completionHandler(true, nil, nil, nil)
    }
    
    func verifyCode(headers: HTTPHeaders, verificationCode: Int, completionHandler: @escaping (Bool, String?) -> Void) {
        completionHandler(true, nil)
    }
}
