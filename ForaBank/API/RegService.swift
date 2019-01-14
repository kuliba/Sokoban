//
//  RegService.swift
//  ForaBank
//
//  Created by Sergey on 12/01/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class RegService: RegServiceProtocol {
    

    private let baseURLString: String
    private var cardNumber: String? = nil
    private var login: String? = nil
    private var password: String? = nil
    private var phone: String? = nil
    private var verificationCode: Int? = nil
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    func checkClient(headers: HTTPHeaders,
                     cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
        let url = baseURLString + "registration/checkClient"
        print(url)
        let parameters: [String: AnyObject] = [
            "cardNumber": cardNumber as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "phone": phone as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]
        print("registration/checkClient parameters \(parameters))")
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("error1")
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage)
                    
                    return
                }
                switch response.result {
                case .success:
                    print("registration/checkClient result: \(String(describing: response.result.value))")
                    print(response.result.error.debugDescription)
                    self.cardNumber = cardNumber
                    self.login = login
                    self.password = password
                    self.phone = phone
                    self.verificationCode = verificationCode
                    completionHandler(true, nil)
                case .failure(let error):
                    print("error")
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }
    
    func doRegistration(headers: HTTPHeaders,
                        completionHandler: @escaping (Bool, String?) -> Void) {
        let url = baseURLString + "registration/doRegistration"
        print(url)
        let parameters: [String: AnyObject] = [
            "cardNumber": cardNumber as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "phone": phone as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]
        print("registration/doRegistration parameters \(parameters))")
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers:headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("error1")
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage)
                    
                    return
                }
                
                switch response.result {
                case .success:
                    print("registration/doRegistration result: \(String(describing: response.result.value))")
                    print(response.result.error.debugDescription)
                    completionHandler(true, nil)
                case .failure(let error):
                    print("error")
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }
    
    func verifyCode(headers: HTTPHeaders,
                    verificationCode: Int, completionHandler: @escaping (Bool, String?) -> Void) {
        let url = self.baseURLString + "registration/verifyCode"
        print(url)
//        let parameters: [String: AnyObject] = [
//            "token": headers["X-XSRF-TOKEN"] as AnyObject,
//            "verificationCode": verificationCode as AnyObject
//        ]
        let parameters: [String: AnyObject] = [
            "cardNumber": cardNumber as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "phone": phone as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": verificationCode as AnyObject
        ]
        print("registration/verifyCode parameters \(parameters))")
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil)
                    return
                }
                
                switch response.result {
                case .success:
                    print("registration/verifyCode result: \(String(describing: response.result.value))")
                    completionHandler(true,nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }
}
