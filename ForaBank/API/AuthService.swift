//
//  AuthService.swift
//  ForaBank
//
//  Created by Sergey on 17/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class AuthService: AuthServiceProtocol {
    
    private let baseURLString: String
    
    private var isSigned: Bool = false
    private var login: String? = nil
    private var password: String? = nil
    
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    func isSignedIn(completionHandler: @escaping (_ success:Bool) -> Void) {
        completionHandler(isSigned)
    }
    
    func csrf(headers: HTTPHeaders, completionHandler: @escaping (_ success:Bool, _ headers: HTTPHeaders?) -> Void) {
        if isSigned == true {
            completionHandler(true, nil)
            return
        }
        let url = baseURLString + "csrf"
        Alamofire.request(url, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .responseJSON { [unowned self] response in
                
//                print("csrf result: \(response.result)")  // response serialization result
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil)
                    return
                }
                
                switch response.result {
                case .success:
//                        print("JSON: \(json)") // serialized json response
                    var newHeaders: [String : String] = [:]
                    for c in Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.cookies ?? [] {
                        if c.name == "JSESSIONID" {
                            newHeaders[c.name] = c.value
                        }
                    }
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Dictionary<String, Any>,
                        let headerName = data["headerName"] as? String,
                        let token = data["token"] as? String {
                        newHeaders[headerName] = token
                        print("csrf newHeaders \(newHeaders)")
                        completionHandler(true, newHeaders)
                    } else {
                        print("csrf cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil)
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }
    
    func loginDo(headers: HTTPHeaders, login: String, password: String, completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
        if isSigned == true {
            completionHandler(isSigned, nil)
            return
        }
        let url = baseURLString + "login.do"
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]
        print("login.do parameters \(parameters))")
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                print("login.do result: \(response.result)") // response serialization result
//                print("JSON: \(String(describing: response.value))") // serialized json response
//                print("JSON: \(String(describing: response.request?.httpBody))") // serialized json response
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage)
                    return
                }
                switch response.result {
                case .success:
                    print("login.do result: \(String(describing: response.result.value))")
                    self.login = login
                    self.password = password
                    completionHandler(true, nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }
    
    func checkVerificationCode(headers: HTTPHeaders, code: String, completionHandler: @escaping (_ success:Bool) -> Void) {
        if isSigned == true {
            completionHandler(isSigned)
            return
        }
        let url = baseURLString + "verify/checkVerificationCode"
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": code as AnyObject
        ]
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
//                print("verify/checkVerificationCode result: \(response.result)") // response serialization result
//                print("JSON: \(String(describing: response.result.value))") // serialized json response
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false)
                    return
                }
                
                switch response.result {
                case .success:
                    print("verify/checkVerificationCode result: \(String(describing: response.result.value))")
                    self.isSigned = true
                    self.login = nil
                    self.password = nil
                    completionHandler(true)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false)
                }
        }
    }
    
    func logOut(completionHandler: @escaping (_ success:Bool) -> Void) {
        isSigned = false
        completionHandler(true)
    }
}
