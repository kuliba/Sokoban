//
//  OperationsListService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

struct UserSettingsStorage {
    static var auth = false
}

//var OperationsList = [OperationsList]
class UserSettingsService: UserSettingsProtocolService{

    

    let urlString = "https://git.briginvest.ru/dbo/api/v2/rest/addUserSetting"
    let setUrlSettings = "https://git.briginvest.ru/dbo/api/v2/rest/setUserSetting"
    let getUrlSettings = "https://git.briginvest.ru/dbo/api/v2/rest/getUserSettings"
    var operationArray = UserSettings()
    var listService: GetUserSettings?

//    var parametrs: [String: Any]  = ["settingName": "90", "settingSysName": "89626129268", "settingValue": "NameTemplate"]
//    let parameters: [String: Any] = [
//              "settingName": "kod123" as String,
//              "settingSysName": "kod123" as String,
//              "settingValue": "kod123" as String
//          ]
    func addSettings(parameters: [String: Any], headers: HTTPHeaders, completionHandler: @escaping (Bool) -> Void) {
        
          guard let url = Foundation.URL(string: urlString) else { return }
//          let urlRequest = URLRequest(url: url)
                Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                    .validate(statusCode: MultiRange(200..<300, 401..<402))
                    .validate(contentType: ["application/json"])
                    .responseJSON { [unowned self] response in
                        print("parametri add", parameters)
        //                print("verify/checkVerificationCode result: \(response.result)") // response serialization result
        //                print("JSON: \(String(describing: response.result.value))") // serialized json response
                        guard let json = response.result.value as? Dictionary<String, Any>,
                            let result = json["result"] as? String, result == "OK" else {
                                print("\(String(describing: response.result.value as? Dictionary<String, Any>)) \(self)")
                                completionHandler(false)
                                return
                        }

                        switch response.result {
                        case .success:
                            print("add Settings result: \(String(describing: response.result.value))")
                          
                            completionHandler(true)
                        case .failure(let error):
                            print("\(error) \(self)")
                            completionHandler(false)
                        }
                }
      }
    func setSettings(parameters: [String: Any], headers: HTTPHeaders, completionHandler: @escaping (Bool) -> Void) {
        guard let url = Foundation.URL(string: setUrlSettings) else { return }
//        let urlRequest = URLRequest(url: url)
         Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                         .validate(statusCode: MultiRange(200..<300, 401..<402))
                         .validate(contentType: ["application/json"])
                         .responseJSON { [unowned self] response in
                            print("parametri set", parameters)
             //                print("verify/checkVerificationCode result: \(response.result)") // response serialization result
             //                print("JSON: \(String(describing: response.result.value))") // serialized json response
                             guard let json = response.result.value as? Dictionary<String, Any>,
                                 let result = json["result"] as? String, result == "OK" else {
                                     print("\(String(describing: response.result.value as? Dictionary<String, Any>)) \(self)")
                                     completionHandler(false)
                                     return
                             }

                             switch response.result {
                             case .success:
                                 print("set Settings result: \(String(describing: response.result.value))")
                               
                                 completionHandler(true)
                             case .failure(let error):
                                 print("\(error) \(self)")
                                 completionHandler(false)
                             }
                     }
    }
    func getSettings(headers: HTTPHeaders, completionHandler: @escaping (Bool, GetUserSettings?, String?) -> Void) {
        guard let url = Foundation.URL(string: getUrlSettings) else { return }
        let _ = URLRequest(url: url)
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { response in
                let json = response.data
                let _ = response.result
            do{
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(GetUserSettings.self, from: json!)
                print(jsonData)
                self.listService = jsonData
                completionHandler(true, self.listService, "123test")
            } catch {
                print(error)
            }
        }
    }
    

}
