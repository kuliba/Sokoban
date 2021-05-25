//
//  PushNotificationService.swift
//  ForaBank
//
//  Created by Дмитрий on 08.04.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

class PushNotificationService: PushNotificationProtocol {
    
    private let host: Host
    init(host: Host) {
      self.host = host
    }

    
    func installPushDevice(headers: HTTPHeaders, parameters: [String : Any], auth: Bool, completionHandler: @escaping (Bool, String) -> Void) {
//            var products = [Product]()
//        let headers = NetworkManager.shared().headers
        var url: URLConvertible
        if auth{
            print("push_device/registerPushDeviceForUser")
             url = host.apiBaseURL + "push_device_user/registerPushDeviceForUser"
        } else {
            print("push_device/installPushDevice")
             url = host.apiBaseURL + "push_device/installPushDevice"
        }

            Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: MultiRange(200..<300, 401..<402))
                .validate(contentType: ["application/json"])
                .responseJSON { [unowned self] response in

                    if let json = response.result.value as? Dictionary<String, Any>,
                        let errorMessage = json["errorMessage"] as? String {
                        print("\(errorMessage) \(self)")
                        completionHandler(false, errorMessage)
                        return
                    }

                    switch response.result {
                    case .success:
                        if let json = response.result.value as? Dictionary<String, Any>, let data = json["data"] as? Array<Any> {
                            
                            completionHandler(true, "nil")
                        } else {
                            print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                            completionHandler(false, "nil")
                        }

                    case .failure(let error):
                        print("rest/getDepositList \(error) \(self)")
                        completionHandler(false, "nil")
                    }
            }
    }
    
    func checkPushDevice(headers: HTTPHeaders, parameters: [String : Any], auth: Bool, completionHandler:  @escaping (Bool, String) -> Void) {
        //            var products = [Product]()
        let headers = NetworkManager.shared().headers

        var url: URLConvertible
        if auth{
             url = host.apiBaseURL + "push_device_user/checkPushDeviceForUser"
        } else {
            url = host.apiBaseURL + "push_device/checkPushDevice"
        }
            Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                            if let json = response.result.value as? Dictionary<String, Any>,
                                let errorMessage = json["errorMessage"] as? String {
                                print("\(errorMessage) \(self)")
                                completionHandler(false, errorMessage)
                                return
                            }

                            switch response.result {
                            case .success:
                                if let json = response.result.value as? Dictionary<String, Any> {
                                    let jsonData = try? newJSONDecoder().decode(BriginvestResponse<Bool>.self, from: response.data ?? Data())
                                    if jsonData?.data == true {
                                        completionHandler(false, "Error")
                                    } else {
                                    completionHandler(true, "nil")
                                    }
                                } else {
                                    print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                                    completionHandler(false, "nil")
                                }

                            case .failure(let error):
                                print("rest/getDepositList \(error) \(self)")
                                completionHandler(false, "nil")
                            }
                    }
            }


    
    func uninstallPushDevice(headers: HTTPHeaders, completionHandler: @escaping (Bool, String) -> Void) {
        //            var products = [Product]()
        let headers = NetworkManager.shared().headers
        let parametersForUninstall = [
        "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
        "FcmToken": FCMToken.fcmToken as AnyObject,
        "model": UIDevice().model,
         "operationSystem": "IOS"
        ] as [String : Any]
        let url = host.apiBaseURL + "push_device/uninstallPushDevice"
        
            Alamofire.request(url, method: HTTPMethod.post, parameters: parametersForUninstall, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                            if let json = response.result.value as? Dictionary<String, Any>,
                                let errorMessage = json["errorMessage"] as? String {
                                print("\(errorMessage) \(self)")
                                completionHandler(false, errorMessage)
                                return
                            }

                            switch response.result {
                            case .success:
                                if let json = response.result.value as? Dictionary<String, Any> {
                                    let jsonData = try? newJSONDecoder().decode(BriginvestResponse<Bool>.self, from: response.data ?? Data())
                                    if jsonData?.data == true {
                                        completionHandler(false, "Error")
                                    } else {
                                    completionHandler(true, "nil")
                                    }
                                } else {
                                    print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                                    completionHandler(false, "nil")
                                }

                            case .failure(let error):
                                print("rest/getDepositList \(error) \(self)")
                                completionHandler(false, "nil")
                            }
                    }
            }
    
}
