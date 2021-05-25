/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

//protocol PreparePaymentProtocol {
//    func paymentInfo{
//
//    }
//}

protocol PreparePaymentDelegate {
    func preparePayment(_ preparePayment: DataClassPayment)
}

class PaymentServices: IPaymetsApi {

    private let host: Host
    
    var preparePayment = DataClassPayment(payerAccountNumber: "", payeeCardNumber: "", payeeAccountNumber: "", payeePhone: "", payeeName: "", amount: 0, currencyAmount: "", commission: [])
    
    init(host: Host) {
        self.host = host
    }
//    var prepare = PreparePayment?()
    var delegate: PreparePaymentDelegate?


    func getPaymentsList(completionHandler: @escaping (Bool, [Operations]?) -> Void) {
        let url = host.apiBaseURL + "rest/getOperatorsList"
        let headers = NetworkManager.shared().headers
        var payments = [Operations]()

        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, payments)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Dictionary<String, Any>> {
                        for cardData in data {
                            if cardData.isEmpty {
//                                let cardDataNew = cardData as? Dictionary<String, Any>
                                let name = cardData["name"] as? String


                                let details = cardData["details"] as? Dictionary<String, Any>
                                let code = details!["code"] as? String?




                                let operators = cardData["operators"] as? Array<Dictionary<String, Any>>

                                for operators in operators! {

                                    let nameList = operators["nameList"] as? Array<Any>
                                    for nameList in nameList! {

                                        let value = nameList as? Dictionary<String , Any>
                                        let nameOperators = value?["value"] as? String
                                        _ = operators["code"] as? String


                                        let payment = Operations(name: name!, details: [Details](), code: code!, nameOperators: nameOperators)
                                        payments.append(payment)

                                    }
                                }
                            }

                            print(payments)
                        }
                        completionHandler(true, payments)
                    } else {
                        print("rest/getCardList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, payments)
                    }

                case .failure(let error):
                    print("rest/getCardList \(error) \(self)")
                    completionHandler(false, payments)
                }
        }
    }

    func allPaymentOptions(completionHandler: @escaping (Bool, [PaymentOption]?) -> Void) {
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "com.payment.options")

        var paymentOptions: Array<PaymentOption> = []

        dispatchQueue.async(group: dispatchGroup, execute: DispatchWorkItem(block: {
            dispatchGroup.enter()
            NetworkManager.shared().getCardList { (success, cards) in
                if success, let nonNilCards = cards {
                    let options = nonNilCards.compactMap({ (card) -> PaymentOption? in
                        return PaymentOption(id: card.id, name: card.name ?? "", type: .paymentOption, sum: card.balance, number: card.number , maskedNumber: card.maskedNumber, provider: card.type?.rawValue ?? "", productType: .card, maskSum: maskSum(sum: card.balance), currencyCode: card.currencyCode, accountNumber: card.accountNumber, productName: card.product)
                    })
                    paymentOptions.append(contentsOf: options)
                }
                dispatchGroup.leave()
            }
        }))
//        dispatchQueue.async(group: dispatchGroup, execute: DispatchWorkItem(block: {
//            dispatchGroup.enter()
//            NetworkManager.shared().getProducts { ( success, cards) in
//                if success, let nonNilCards = cards?.filter({ $0.status != nil}) {
//                    let options = nonNilCards.compactMap({ (card) -> PaymentOption? in
//                        return PaymentOption(id: card.id, name: card.name ?? "", type: .paymentOption, sum: card.balance, number: card.number, maskedNumber: card.maskedNumber, provider: card.productType.rawValue, productType: .account, maskSum: maskSum(sum: card.balance), currencyCode: card.currencyCode, accountNumber: card.accountNumber, productName: card.productName)
//                    })
//                    paymentOptions.append(contentsOf: options)
//                }
//                dispatchGroup.leave()
//            }
//        }))
        dispatchQueue.async(group: dispatchGroup, execute: DispatchWorkItem(block: {
            dispatchGroup.enter()
            NetworkManager.shared().getDepos { (success, deposits) in
                if success, let nonNilDeposits = deposits {
                    let options = nonNilDeposits.compactMap({ (deposit) -> PaymentOption? in
                        return PaymentOption(id: deposit.id, name: deposit.productName, type: .paymentOption, sum: deposit.balance, number: deposit.accountNumber, maskedNumber: deposit.accountNumber, provider: deposit.productName, productType: .account, maskSum: maskSum(sum: deposit.balance), currencyCode: deposit.currencyCode, accountNumber: deposit.accountNumber, productName: deposit.productName)
                    })
                    paymentOptions.append(contentsOf: options)
                }
                dispatchGroup.leave()
            }
        }))

        dispatchGroup.notify(queue: dispatchQueue) {
            completionHandler(true, paymentOptions)
        }
    }

    func prepareCard2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeeCardNumber": destinationNumber as AnyObject,
            "payerCardNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject
        ]

        Alamofire.request(Host.shared.apiBaseURL + "rest/prepareCard2Card", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
//                        let jsonDecoder = try? newJSONDecoder().decode(self.prepare, from: response.result.value as! Data)
                        if let data = json["data"] as? Dictionary<String, Any>{
                         let payeeName = data["payeeName"] as? String
                            let currencyAmount = data["currencyAmount"] as? String
                            preparePayment.payeeName = payeeName ?? ""
                            preparePayment.currencyAmount = currencyAmount ?? ""
                         }
                        completionHandler(true, token, self.preparePayment)
                        
                    } else {
                        print("rest/prepareCard2Card cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil,nil)
                    }

                case .failure(let error):
                    print("rest/prepareCard2Card \(error)")
                    completionHandler(false, nil,nil)
                }
        }
    }

    func prepareCard2Account(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeeAccountNumber": destinationNumber as AnyObject,
            "payerCardNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject
        ]

        Alamofire.request(Host.shared.apiBaseURL + "rest/prepareCard2Account", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
                        
                        if let data = json["data"] as? Dictionary<String, Any>{
                         let payeeName = data["payeeName"] as? String
                            let currencyAmount = data["currencyAmount"] as? String
                            preparePayment.payeeName = payeeName ?? ""
                            preparePayment.currencyAmount = currencyAmount ?? ""
                         }
                        completionHandler(true, token, self.preparePayment)
                        
                    } else {
                        print("rest/prepareCard2Account cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil, nil)
                    }

                case .failure(let error):
                    print("rest/prepareCard2Account \(error)")
                    completionHandler(false, nil, nil)
                }
        }
    }

    func prepareCard2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeePhone": destinationNumber as AnyObject,
            "payerCardNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject
        ]
        print("parameters = ", parameters)
        Alamofire.request(Host.shared.apiBaseURL + "rest/prepareCard2Phone", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
                       if let data = json["data"] as? Dictionary<String, Any>{
                        let payeeName = data["payeeName"] as? String
                        let currencyAmount = data["currencyAmount"] as? String
                        preparePayment.payeeName = payeeName ?? ""
                        preparePayment.currencyAmount = currencyAmount ?? ""
                        }
                        completionHandler(true, token, preparePayment)
                    } else {
                        print("rest/prepareCard2Phone cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil, nil)
                    }

                case .failure(let error):
                    print("rest/prepareCard2Phone \(error)")
                    completionHandler(false, nil, nil)
                }
        }
    }

    func prepareAccount2Account(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeeAccountNumber": destinationNumber as AnyObject,
            "payerAccountNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject,
        ]

        Alamofire.request(Host.shared.apiBaseURL + "rest/prepareAccount2Account", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
                        if let data = json["data"] as? Dictionary<String, Any>{
                         let payeeName = data["payeeName"] as? String
                            let currencyAmount = data["currencyAmount"] as? String
                            preparePayment.payeeName = payeeName ?? ""
                            preparePayment.currencyAmount = currencyAmount ?? ""
                        }
                        completionHandler(true, token, self.preparePayment)
                        
                    } else {
                        print("rest/prepareAccount2Account cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil, nil)
                    }

                case .failure(let error):
                    print("rest/prepareAccount2Account \(error)")
                    completionHandler(false, nil, nil)
                }
        }
    }

    func prepareAccount2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeeCardNumber": destinationNumber as AnyObject,
            "payerAccountNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject
        ]

        Alamofire.request(Host.shared.apiBaseURL + "rest/prepareAccount2Card", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
                        if let data = json["data"] as? Dictionary<String, Any>{
                         let payeeName = data["payeeName"] as? String
                            let currencyAmount = data["currencyAmount"] as? String
                            preparePayment.payeeName = payeeName ?? ""
                            preparePayment.currencyAmount = currencyAmount ?? ""
                            
                        }
                        completionHandler(true, token, self.preparePayment)
                        
                    } else {
                        print("rest/prepareAccount2Card cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil, nil)
                    }

                case .failure(let error):
                    print("rest/prepareAccount2Card \(error)")
                    completionHandler(false, nil, nil)
                }
        }
    }

    func prepareAccount2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?, DataClassPayment?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeePhone": destinationNumber as AnyObject,
            "payerAccountNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject,
        ]

        Alamofire.request(Host.shared.apiBaseURL + "rest/prepareAccount2Phone", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
                        if let data = json["data"] as? Dictionary<String, Any>{
                         let payeeName = data["payeeName"] as? String
                            let currencyAmount = data["currencyAmount"] as? String
                            preparePayment.payeeName = payeeName ?? ""
                            preparePayment.currencyAmount = currencyAmount ?? ""
                            
                        }
                        completionHandler(true, token, self.preparePayment)
                        
                    } else {
                        print("rest/prepareAccount2Phone cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil, nil)
                    }

                case .failure(let error):
                    print("rest/prepareAccount2Phone \(error)")
                    completionHandler(false, nil, nil)
                }
        }
    }

    func makeCard2Card(code: String, completionHandler: @escaping (Bool) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": Int(code) as AnyObject
        ]

        Alamofire.request(Host.shared.apiBaseURL + "rest/makeCard2Card", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage)")
                    completionHandler(false)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let _ = json["result"] as? String {
                        completionHandler(true)
                    } else {
                        print("rest/makeCard2Card cant parse json \(String(describing: response.result.value))")
                        completionHandler(false)
                    }

                case .failure(let error):
                    print("rest/makeCard2Card \(error)")
                    completionHandler(false)
                }
        }
    }
}
