//
//  NetworkManager.swift
//  ForaBank
//
//  Created by Sergey on 11/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

typealias CompletionHandler = (_ success:Bool) -> Void

class NetworkManager {
    
    // MARK: - Properties
    
    private static var sharedNetworkManager: NetworkManager = {
        let networkManager = NetworkManager(baseURLString: "https://git.briginvest.ru/dbo/api/v2/")
        
        // Configuration
        
        
        return networkManager
    }()
    
    private var isSigned: Bool? = nil
    private var login: String? = nil
    private var password: String? = nil
    // MARK: -
    
    let baseURLString: String
    var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    // Initialization
    
    private init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    // MARK: - Accessors
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
    
    func csrf(completionHandler: @escaping CompletionHandler) {
        if isSigned == true {
            completionHandler(true)
            return
        }
//        else {
//            completionHandler(true)
//            return
//        }
        let url = baseURLString + "csrf"
        Alamofire.request(url, headers: self.headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                print("Result: \(response.result)")  // response serialization result
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        //                print("JSON: \(json)") // serialized json response
                        for c in Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.cookies ?? [] {
                            if c.name == "JSESSIONID" {
                                self.headers.merge([c.name : c.value],
                                                   uniquingKeysWith: { (c1, c2) -> String in
                                                    return c2
                                })
                            }
                        }
                        let dict = json as! Dictionary<String, Any>
                        let data = dict["data"] as! Dictionary<String, Any>
                        let headerName = data["headerName"] as! String
                        let token = data["token"] as! String
                        
                        self.headers.merge([headerName : token],
                                           uniquingKeysWith: { (c1, c2) -> String in
                                            return c2
                        })
//                        print(self.headers)
                        completionHandler(true)
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false)
                }
        }
        
//        Alamofire.request("https://httpbin.org/get").responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }
//        }
    }
    
    func isSignedIn(completionHandler: @escaping CompletionHandler) {
        if isSigned != nil {
            completionHandler(isSigned!)
            return
        }
        let url = baseURLString + "checkOffer"
        Alamofire.request(url, method: HTTPMethod.post, headers: self.headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
//                print("Request: \(String(describing: response.request))")   // original url request
//                print("Request headers: \(response.request?.allHTTPHeaderFields)")   // original url request
//                print("Response: \(String(describing: response.response))") // http url response
//                print("Response headers: \(response.response?.allHeaderFields)") // http url response
//                print("Result: \(response.result)")                         // response serialization result
                
//                if let json = response.result.value {
//                    print("JSON: \(json)") // serialized json response
//                }
//
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)") // original server data as UTF8 string
//                }
                switch response.result {
                case .success:
//                    print("Validation Successful \(self)")
                    self.isSigned = true
                    completionHandler(true)
                case .failure(let error):
                    print("\(error) \(self)")
                    self.isSigned = false
                    completionHandler(false)
                }
        }
    }
    
    func loginDo(login: String, password: String, completionHandler: @escaping CompletionHandler) {
        if isSigned == true {
            completionHandler(isSigned!)
            return
        }
//        else {
//            completionHandler(true)
//            return
//        }
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
    
    func checkVerificationCode(code: String, completionHandler: @escaping CompletionHandler) {
        if isSigned == true {
            completionHandler(isSigned!)
            return
        }
//        else {
//            isSigned = true
//            completionHandler(true)
//            return
//        }
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
                    //                    self.isSigned = true
                    completionHandler(true)
                case .failure(let error):
                    print("\(error) \(self)")
                    //                    self.isSigned = false
                    completionHandler(false)
                }
        }
    }
    
    func logOut(completionHandler: CompletionHandler?) {
        isSigned = false
        if completionHandler != nil {
            completionHandler!(true)
        }
    }
}
