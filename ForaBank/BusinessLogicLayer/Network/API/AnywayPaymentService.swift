//
//  AnywayStep.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 22.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

class AnywayPaymentService: AnywayPaymentProtocol{
    
 
    

    private let host: Host
    init(host: Host) {
      self.host = host
    }

    
    var anywayPaymentBegin = [AnywayPaymentBegin?]()
    var anywayPayment = [AnywayPaymentInputs?]()
    var bankList: BLBankList?
    var makePayment: MPMakePayment?
    let urlString = Host.shared.apiBaseURL + "rest/anywayPaymentBegin"
    var bodyVariable = ""
    var parameters:[String: Any]?

    
    func anywayPaymentBegin(headers: HTTPHeaders, numberCard: String?, puref: String?, completionHandler: @escaping (_ success: Bool,_ data: AnywayPaymentBegin?,_ errorMessage: String?) -> Void) {
           guard let url = Foundation.URL(string: urlString) else { return }
           let _ = URLRequest(url: url)
        guard let purefID = puref else { return }
       
//        var parameters:[String: Any]?
        if numberCard?.count ?? 0 < 14{
            self.bodyVariable = "accountID"
            self.parameters = ["\(self.bodyVariable)": Int(numberCard!) as Any, "puref": "\(purefID)" as String]
        } else {
            self.bodyVariable = "cardNumber"
            self.parameters = ["\(self.bodyVariable)": "\(numberCard!)" as String, "puref": "\(purefID)" as String]
        }
        
        if numberCard == "BANK_DEF"{
            self.bodyVariable = "type"

        }
        
        var parametrs: [String: Any] = self.parameters ?? [String: Any]()

           Alamofire.request(urlString, method: HTTPMethod.post, parameters: parametrs, encoding: JSONEncoding.default, headers: headers)
           .validate(statusCode: MultiRange(200..<300, 401..<406))
               .responseJSON { response in
                
                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    let json = [response.data]
                    let decoder = newJSONDecoder()
                    let jsonData = try? decoder.decode(ForaBank.AnywayPaymentBegin.self, from: json[0]!)
                    self.anywayPaymentBegin = [jsonData]
                    completionHandler(false, nil, self.anywayPaymentBegin[0]?.errorMessage)
                    return
                }
                
                switch response.result{
                case .success:
                    do{
                        let json = [response.data]
                        let decoder = newJSONDecoder()
                        let jsonData = try? decoder.decode(ForaBank.AnywayPaymentBegin.self, from: json[0]!)
                        self.anywayPaymentBegin = [jsonData]
//                        self.AnywayPayment(headers: headers) { (success, anywayPayment, errorMessage) in
//
//                        }
                        completionHandler(true, self.anywayPaymentBegin[0]!, nil)
                    } catch {
                        print(error)
                    }
                case . failure( _):
                    print("failture")
//                    completionHandler(false, self.anywayPaymentBegin[0]!, "Ошибка выбора карты")
                }
           }
       }
    
    func AnywayPayment(headers: HTTPHeaders, completionHandler: @escaping (Bool?, [AnywayPaymentInputs?], String?) -> Void) {
                    let headers = NetworkManager.shared().headers
                    let url = host.apiBaseURL + "rest/anywayPayment"
//                    let parametrs: [String: Any] = [:]

                    Alamofire.request(url, method: HTTPMethod.post, parameters: Dictionary(), encoding: JSONEncoding.default, headers: headers)
                            .validate(statusCode: MultiRange(200..<300, 401..<402))
                            .validate(contentType: ["application/json"])
                            .responseJSON { [unowned self] response in
                                
                                if let json = response.result.value as? Dictionary<String, Any>,
                                    let errorMessage = json["errorMessage"] as? String {
                                    print("\(errorMessage)")
                                    completionHandler(true, self.anywayPayment, "\(errorMessage)")
                                    return
                                }
                                
                                switch response.result{
                                case .success:
                                    do{
                                        let json = response.data
                                        let decoder = JSONDecoder()
                                        let jsonData = try? decoder.decode(ForaBank.AnywayPaymentInputs.self, from: json!)
                                        self.anywayPayment = [jsonData]
                                        completionHandler(true, self.anywayPayment, nil)
                                    } catch {
                                        print(error)
                                    }
                                case .failure:
                                    completionHandler(false, self.anywayPayment, "errorMessage")
                                }
                    }
    }
    
    func AnywayPaymentFinal(memberId: String?, amount: String?, numberPhone: String?, parameters: [Additional]?, headers: HTTPHeaders, completionHandler: @escaping (Bool?, [AnywayPaymentInputs?], String?) -> Void) {
                    let headers = NetworkManager.shared().headers
                    let url = host.apiBaseURL + "rest/anywayPayment"
        let cleanPhoneNumber = numberPhone?.dropFirst()
        
//        var parametrs =   ["additional" : [["fieldid": 1, "fieldname": "SumSTrs", "fieldvalue": "120.00"], ["fieldid": 2, "fieldname": "RecipientID", "fieldvalue": "0005310217"], ["fieldid": 3, "fieldname": "BankRecipientID", "fieldvalue": "1crt88888881"]]]
        
        var parametrs: Parameters?
        
        switch memberId {
        case "setDefaultBank":
            parametrs =   ["additional" : [["fieldid": 1, "fieldname": "NUMBER", "fieldvalue": "\(numberPhone!)"]]]

        case "codeVerification":
            parametrs =   ["additional" : [["fieldid": 1, "fieldname": "OTR", "fieldvalue": "\(amount!)"]]]
        case "mobilePhone":
//            parametrs =   ["additional" : [["fieldid": 1, "fieldname": "NUMBER", "fieldvalue": "\(numberPhone?.dropFirst(1) ?? "")"], ["fieldid": 2, "fieldname": "SumSTrs", "fieldvalue": "\(amount!)"]]]
            parametrs =   ["additional" : [["fieldid": 1, "fieldname": "P1", "fieldvalue": "\(numberPhone?.dropFirst(1) ?? "")"], ["fieldid": 2, "fieldname": "SumSTrs", "fieldvalue": "\(amount!)"]]]

        case "contactAdress":
            guard let parametersItem = parameters else {
                return
            }
            var dataBody = [[String: Any]]()
            for i in parametersItem {
                dataBody.append(["fieldid": i.fieldid ?? 0, "fieldname": i.fieldname ?? "", "fieldvalue": i.fieldvalue ?? ""])
            }
//            func addParametrs(count: Int, parametr: Additional ){
//                for i in parametersItem {
//                    dataBody.append(["fieldid": i.fieldid ?? 0, "fieldname": i.fieldname ?? "", "fieldvalue": i.fieldvalue ?? ""])
//                }
//            }
            parametrs = ["additional" :dataBody]
        default:
            parametrs =   ["additional" : [["fieldid": 1, "fieldname": "SumSTrs", "fieldvalue": "\(amount!)"], ["fieldid": 2, "fieldname": "RecipientID", "fieldvalue": "\(cleanPhoneNumber ?? "")"], ["fieldid": 3, "fieldname": "BankRecipientID", "fieldvalue": "\(memberId!)"]]]
        }
//

 
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: parametrs, encoding: JSONEncoding.default, headers: headers)
                            .validate(statusCode: MultiRange(200..<300, 401..<402))
                            .validate(contentType: ["application/json"])
                            .responseJSON { [unowned self] response in
                            
                                
                                if let json = response.result.value as? Dictionary<String, Any>,
                                    let errorMessage = json["errorMessage"] as? String {
                                    print("\(errorMessage)")
                                    completionHandler(false, self.anywayPayment, "\(errorMessage)")
                                    return
                                }
                                
                                switch response.result{
                                case .success:
                                    do{
                                        let json = response.data
                                        let decoder = JSONDecoder()
                                        let jsonData = try? decoder.decode(ForaBank.AnywayPaymentInputs.self, from: json!)
                                        self.anywayPayment = [jsonData]
//                                        AnywayPaymentFinal(headers: headers) { (success, anywayPayment, errorMessage) in
//
//                                        }
                                        completionHandler(true, self.anywayPayment, nil)
                                    } catch {
                                        completionHandler(false, self.anywayPayment, "\(anywayPayment[0]?.errorMessage ?? "")")
                                    }
                                case .failure:
                                    completionHandler(false, self.anywayPayment, "\(anywayPayment[0]?.errorMessage ?? "")")
                                }
                    }
    }
    
    func anywayPaymentMake(code: String, completionHandler: @escaping (Bool, String?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "verificationCode": code as AnyObject
        ]

        Alamofire.request(Host.shared.apiBaseURL + "rest/anywayPaymentMake", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage)")
                    completionHandler(false, errorMessage)
                    return
                }

                switch response.result {
                case .success:
                    do{
                        let json = response.data
                        let decoder = JSONDecoder()
                        let jsonData = try? decoder.decode(ForaBank.MPMakePayment.self, from: json!)
                        self.makePayment = jsonData
//                                        AnywayPaymentFinal(headers: headers) { (success, anywayPayment, errorMessage) in
//
//                                        }
                        completionHandler(true, nil)
                    } catch {
                        print("rest/makeCard2Card cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, "")
                    }
                case .failure(let error):
                    let json = response.data
                    let decoder = JSONDecoder()
                    let jsonData = try? decoder.decode(ForaBank.MPMakePayment.self, from: json!)
                    self.makePayment = jsonData
//                                        AnywayPaymentFinal(headers: headers) { (success, anywayPayment, errorMessage) in
//
//                                        }
                    completionHandler(false, makePayment?.data?.errorMessage)
                }
        }
    }
    
    func findBankList(headers: HTTPHeaders, completionHandler: @escaping (Bool, BLBankList?, String) -> Void) {
        let headers = NetworkManager.shared().headers
      

        Alamofire.request(Host.shared.apiBaseURL + "/rest/fastPaymentBanksList", method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { response in

                switch response.result{
                case .success:
                    do{
                        let json = response.data
                        let decoder = JSONDecoder()
                        let jsonData = try? decoder.decode(ForaBank.BLBankList.self, from: json!)
                        self.bankList = jsonData
                        completionHandler(true, self.bankList, "\(jsonData?.errorMessage ?? "")")
                    } catch {
                        print(error)
                    }
                case .failure:
                    completionHandler(false, self.bankList, "\(String(describing: self.bankList?.errorMessage))")
                }
        }
    }
}



