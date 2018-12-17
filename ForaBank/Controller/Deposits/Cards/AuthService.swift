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
    
    let baseURLString: String
    
    var isSigned: Bool = false
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
            .validate(statusCode: 200..<300)
            .responseJSON { [unowned self] response in
                
                print("Result: \(response.result)")  // response serialization result
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        //                print("JSON: \(json)") // serialized json response
                        var newHeaders: [String : String] = [:]
                        for c in Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.cookies ?? [] {
                            if c.name == "JSESSIONID" {
                                newHeaders[c.name] = c.value
                            }
                        }
                        if let dict = json as? Dictionary<String, Any>,
                            let data = dict["data"] as? Dictionary<String, Any>,
                            let headerName = data["headerName"] as? String,
                            let token = data["token"] as? String {
                            newHeaders[headerName] = token
                            completionHandler(true, newHeaders)
                        } else {
                            completionHandler(false, nil)
                        }
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }
    
    func loginDo(headers: HTTPHeaders, login: String, password: String, completionHandler: @escaping (_ success:Bool) -> Void) {
        if isSigned == true {
            completionHandler(isSigned)
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
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                print("Result: \(response.result)") // response serialization result
                
                switch response.result {
                case .success:
                    //                    print("Validation Successful \(self)")
                    //                    self.isSigned = true
                    self.login = login
                    self.password = password
                    completionHandler(true)
                case .failure(let error):
                    print("\(error) \(self)")
                    //                    self.isSigned = false
                    completionHandler(false)
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
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                //                print("Result: \(response.result)") // response serialization result
                
                switch response.result {
                case .success:
                    //                    print("Validation Successful \(self)")
                    self.isSigned = true
                    self.login = nil
                    self.password = nil
                    completionHandler(true)
                case .failure(let error):
                    print("\(error) \(self)")
                    //                    self.isSigned = false
                    completionHandler(false)
                }
        }
    }
    
    func logOut(completionHandler: @escaping (_ success:Bool) -> Void) {
        isSigned = false
        completionHandler(true)
    }
}
