/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class TestAuthService: AuthServiceProtocol {
    var isSigned: Bool = false
    private var profile: Profile? = nil
    
    func isSignedIn(completionHandler: @escaping (Bool) -> Void) {
        completionHandler(isSigned)
    }
    
//    func csrf(headers: HTTPHeaders, completionHandler: @escaping (Bool, HTTPHeaders?) -> Void) {
//        completionHandler(true, nil)
//    }
    
    func csrf(headers: HTTPHeaders, completionHandler: @escaping (_ success:Bool, _ headers: HTTPHeaders?) -> Void) {
        if isSigned == true {
            completionHandler(true, nil)
            return
        }
        let url = "https://git.briginvest.ru/dbo/api/v2/csrf"
        let c1 = HTTPCookie.init(properties: [HTTPCookiePropertyKey.value : headers["JSESSIONID"] ?? "",
                                              HTTPCookiePropertyKey.name: "JSESSIONID",
                                              HTTPCookiePropertyKey.domain : "git.briginvest.ru",
                                              HTTPCookiePropertyKey.secure : false,
                                              HTTPCookiePropertyKey.path : "/"])
        let c2 = HTTPCookie.init(properties: [HTTPCookiePropertyKey.name : "XSRF-TOKEN",
                                              HTTPCookiePropertyKey.value : headers["X-XSRF-TOKEN"] ?? "",
                                              HTTPCookiePropertyKey.domain : "git.briginvest.ru",
                                              HTTPCookiePropertyKey.secure : false,
                                              HTTPCookiePropertyKey.path : "/"])
        Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(c1!)
        Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(c2!)

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
//                        print("cookie \(c)")
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
    
    func loginDo(headers: HTTPHeaders, login: String, password: String, completionHandler: @escaping (Bool, String?) -> Void) {
        completionHandler(true, nil)
    }
    
    func checkVerificationCode(headers: HTTPHeaders, code: String, completionHandler: @escaping (Bool) -> Void) {
        isSigned = true
        completionHandler(true)
    }
    
    func logOut(completionHandler: @escaping (Bool) -> Void) {
        isSigned = false
        profile = nil
        completionHandler(true)
    }
    
    func getProfile(headers: HTTPHeaders, completionHandler: @escaping (Bool, Profile?, String?) -> Void) {
        profile = Profile.init(firstName: "Александр",
                               lastName: "Крюков",
                               imageURL: "image_profile_samplephoto")
//        completionHandler(true, profile, "16: Сессия не авторизована")
        completionHandler(true, profile, nil)
    }
    /*
    func getProfile(headers: HTTPHeaders, completionHandler: @escaping (_ success: Bool, Profile?,_ errorMessage: String?) -> Void) {
        if profile != nil {
            completionHandler(true, profile, nil)
            return
        }
        print("getProfile headers: \(headers)")
        let url = "https://git.briginvest.ru/dbo/api/v2/rest/getPerson"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { [unowned self] response in
//                print("getProfile result: \(String(data: response.data!, encoding: String.Encoding.utf8))")  // response serialization result
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil, errorMessage)
                    return
                }
                
                switch response.result {
                case .success:
                    //                    print("JSON: \(json)") // serialized json response
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Dictionary<String, Any>,
                        let firstName = data["firstname"] as? String,
                        let lastName = data["lastname"] as? String {
                        var imageURL: String? = nil
                        if let users = data["users"] as? Array<Dictionary<String,Any>>,
                            let imageUrl = users[0]["userPic"] as? String {
                            imageURL = imageUrl
                        }
                        self.profile = Profile.init(firstName: firstName,
                                                    lastName: lastName,
                                                    imageURL: imageURL)
//                        print("/rest/getPerson result: \(String(describing: response.result.value))")
                        print("rest/getPerson result: \(firstName), \(lastName), \(imageURL ?? "nil")")
                        completionHandler(true, self.profile, nil)
                    } else {
                        print("rest/getPerson cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil, "")
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil, "get profile result validation failure")
                }
        }
    }*/
}
