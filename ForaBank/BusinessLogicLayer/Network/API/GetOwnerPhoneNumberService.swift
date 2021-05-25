//
//  GetOwnerPhoneNumberService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 06.07.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

class GetOwnerPhoneNumberService: GetOwnerPhoneNumberProtocol{
        
    

        let urlString = "https://git.briginvest.ru/dbo/api/v2/rest/getOwnerPhoneNumber"
        var operationArray = UserSettings()
        var listService: GetUserSettings?

    //    var parametrs: [String: Any]  = ["settingName": "90", "settingSysName": "89626129268", "settingValue": "NameTemplate"]
       
    func getOwnerPhoneNumber(headers: HTTPHeaders,phoneNumber:String?, completionHandler: @escaping (Bool?, String?) -> Void) {
       let newString =  phoneNumber?.removeWhitespace()
        let newString2 = newString?.replace(string: "(", replacement: "")
       let newString3 =  newString2?.replace(string: ")", replacement: "")
        let newString4 = newString3?.replace(string: "-", replacement: "")


        let parameters: [String: Any] = [
                             "phoneNumber": "\(newString4!)" as String,
                         ]
              guard let url = Foundation.URL(string: urlString) else { return }
    //          let urlRequest = URLRequest(url: url)
                    Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                        .validate(statusCode: MultiRange(200..<300, 401..<402))
                        .validate(contentType: ["application/json"])
                        .responseJSON { [unowned self] response in
            //                print("verify/checkVerificationCode result: \(response.result)") // response serialization result
            //                print("JSON: \(String(describing: response.result.value))") // serialized json response
                            guard let json = response.result.value as? Dictionary<String, Any>,
                                let result = json["result"] as? String, result == "OK" else {
                                    print("\(String(describing: response.result.value as? Dictionary<String, Any>)) \(self)")
//                                    var errorMessage = json["errorMessage"] as? String
                                    
                                    completionHandler(false, "errorMessage")
                                    return
                            }

                            switch response.result {
                            case .success:
                                print("result: SUCCESS")
                              
                                completionHandler(true, "errorMessage")
                            case .failure(let error):
                                print("\(error) \(self)")
                                completionHandler(false, "errorMessage")
                            }
                    }
          }
}
