/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire



class RegService: RegServiceProtocol {
    
    private let host: Host
    private var cardNumber: String? = nil
    private var login: String? = nil
    private var password: String? = nil
    private var phone: String? = nil
    private var verificationCode: Int? = nil
    var name: String? = nil
    var product: IProduct?

    init(host: Host) {
        self.host = host
    }

    func saveCustomName(headers: HTTPHeaders, id: Int, newName: String, productType: productTypes, completionHandler: @escaping (Bool, String?, Int?, String?) -> Void) {
        var url = ""
        if productType == .AccauntType || productType == .DepositType{
            url = host.apiBaseURL + "rest/saveDepositName"
        }else if productType == .LoanType{
            url = host.apiBaseURL + "rest/saveLoanName"
        }else if productType == .CardType{
            url = host.apiBaseURL + "rest/saveCardName"
        }
        let parameters: [String: AnyObject] = [
            "id": id as AnyObject,
            "name": newName as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("error1")
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage, id, self.name)
                    return
                }

                switch response.result {
                case .success:
                    print(response.result.error.debugDescription)
                    completionHandler(true, nil, id, self.name)
                case .failure(let error):
                    print("error")
                    print("\(error) \(self)")
                    completionHandler(false, nil, id, self.name)
                }
        }
    }
    
    
    func saveLoanName(headers: HTTPHeaders, id: Int, newName: String, completionHandler: @escaping (Bool, String?, Int?, String?) -> Void) {
        let url = host.apiBaseURL + "rest/saveLoanName"
        let parameters: [String: AnyObject] = [
            "id": id as AnyObject,
            "name": newName as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("error1")
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage, id, self.name)
                    return
                }

                switch response.result {
                case .success:
                    print(response.result.error.debugDescription)
                    completionHandler(true, nil, id, self.name)
                case .failure(let error):
                    print("error")
                    print("\(error) \(self)")
                    completionHandler(false, nil, id, self.name)
                }
        }
        
    }

    func saveCardName(headers: HTTPHeaders, id: Double, newName: String, completionHandler: @escaping (Bool, String?, Double?, String?) -> Void) {
        let url = host.apiBaseURL + "rest/saveCardName"
        print(url)
        let parameters: [String: AnyObject] = [
            "id": id as AnyObject,
            "name": newName as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("error1")
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage, id, self.name)

                    return
                }

                switch response.result {
                case .success:
                    print(response.result.error.debugDescription)
                    completionHandler(true, nil, id, self.name)
                case .failure(let error):
                    print("error")
                    print("\(error) \(self)")
                    completionHandler(false, nil, id, self.name)
                }
        }
    }
    
    
    
    func paymentCompany(headers: HTTPHeaders,
                        numberAcoount : String,
                        amount : String,
                        payerCard: String,
                        kppBank : String,
                        innBank : String,
                        bikBank : String,
                        comment: String,
                        nameCompany: String,
                        commission: Double,
    completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ commission: Double?) -> Void) {
        var commissions: Double?
           let url = "https://git.briginvest.ru/dbo/api/v2/rest/prepareExternal"
                 print(url)
                 let date = NSDate()
                 let parameters: [String: AnyObject] = [
                   "amount": amount as AnyObject,
                   "payeeKPP": kppBank as AnyObject,
                   "compilerStatus": "00" as AnyObject,
                   "payeeINN": innBank as AnyObject,
                   "payeeBankBIC": bikBank as AnyObject,
                   "date": "2020-01-28" as AnyObject,
                   "payeeName": nameCompany as AnyObject,
                   "payerCardNumber": payerCard as AnyObject,
                   "payeeAccountNumber": numberAcoount as AnyObject,
                   "payerINN": "0" as AnyObject,
                    "comment": comment as AnyObject
                 ]

                 Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                     .validate(statusCode: MultiRange(200..<300, 401..<402))
                     .validate(contentType: ["application/json"])
                     .responseJSON { [unowned self] response in

                         if let json = response.result.value as? Dictionary<String, Any>,
                             let errorMessage = json["errorMessage"] as? String {
                            
                             print("error1")
                             print("\(errorMessage) \(self)")

                             return
                         }

                         switch response.result {
                         case .success:
                            if let json = response.result.value as? Dictionary<String, Any>,
                            let data = json["data"] as? Array<Any> {
                            for cardData in data {
                                if let cardData = cardData as? Dictionary<String, Any>{
                                    let commissions = cardData["amount"] as? Double
                                    let description = cardData["description"] as? String
                                    print(commission, description!)
                                    var commission = commissions ?? 5000
                                    completionHandler(true, "Error", commission)

                                }
                                completionHandler(false, "Error", commission)

                                }
                            
                            }
                          
                            
                            
                            
                             print(response.result.error.debugDescription)
                         case .failure(let error):
                             print("error")
                             print("\(error) \(self)")
                         }
                 }
             }


    func checkClient(headers: HTTPHeaders,
                     cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        let url = host.apiBaseURL + "registration/checkClient"
        print(url)
        let parameters: [String: AnyObject] = [
            "cardNumber": cardNumber as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "phone": phone as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    var errorMessage = json["errorMessage"] as? String {
                   
                    if errorMessage == "4: Сбой при поиске данных"{
                         errorMessage  = "Карта с таким номером не найдена Пожалуйста, проверьте корректность введённых данных"
                    }
                    print("\(errorMessage) \(self)")
                   
                    completionHandler(false, errorMessage)
                    
                    return
                }
                switch response.result {
                case .success:
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
                        completionHandler: @escaping (Bool, String?, String?, String?) -> Void) {
        let url = host.apiBaseURL + "registration/doRegistration"
        print(url)
        let parameters: [String: AnyObject] = [
            "cardNumber": cardNumber as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "phone": phone as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("error1")
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage, nil, nil)

                    return
                }

                switch response.result {
                case .success:
                    print(response.result.error.debugDescription)
                    completionHandler(true, nil, self.login, self.password)
                case .failure(let error):
                    print("error")
                    print("\(error) \(self)")
                    completionHandler(false, nil, nil, nil)
                }
        }
    }



    func verifyCode(headers: HTTPHeaders,
                    verificationCode: Int, completionHandler: @escaping (Bool, String?) -> Void) {
        let url = host.apiBaseURL + "registration/verifyCode"
        let parameters: [String: AnyObject] = [
            "cardNumber": cardNumber as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "phone": phone as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": verificationCode as AnyObject
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil)
                    return
                }

                switch response.result {
                case .success:
                    print("registration/verifyCode result: \(String(describing: response.result.value))")
                    completionHandler(true, nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }

}
