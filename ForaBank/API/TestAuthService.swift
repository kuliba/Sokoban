//
//  TestAuthService.swift
//  ForaBank
//
//  Created by Sergey on 17/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class TestAuthService: AuthServiceProtocol {
    var isSigned: Bool = false
    
    func isSignedIn(completionHandler: @escaping (Bool) -> Void) {
        completionHandler(isSigned)
    }
    
    func csrf(headers: HTTPHeaders, completionHandler: @escaping (Bool, HTTPHeaders?) -> Void) {
        completionHandler(true, nil)
    }
    
    func loginDo(headers: HTTPHeaders, login: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func checkVerificationCode(headers: HTTPHeaders, code: String, completionHandler: @escaping (Bool) -> Void) {
        isSigned = true
        completionHandler(true)
    }
    
    func logOut(completionHandler: @escaping (Bool) -> Void) {
        isSigned = false
        completionHandler(true)
    }
    
    
}
