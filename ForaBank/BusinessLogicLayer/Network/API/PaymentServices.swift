/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class PaymentServices: IPaymetsApi {

    private let baseURLString: String

    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }

    func getPaymentsList(completionHandler: @escaping (Bool, [Operations]?) -> Void) {
        let url = baseURLString + "rest/getOperatorsList"
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
                            if let cardData = cardData as? Dictionary<String, Any> {
                                let name = cardData["name"] as? String


                                let details = cardData["details"] as? Dictionary<String, Any>
                                var code = details!["code"] as? String?




                                let operators = cardData["operators"] as? Array<Dictionary<String, Any>>

                                for operators in operators! {

                                    let operatorsList = operators as? Dictionary<String , Any>
                                    let nameList = operatorsList?["nameList"] as? Array<Any>
                                    for nameList in nameList! {

                                        let value = nameList as? Dictionary<String , Any>
                                        let nameOperators = value?["value"] as? String
                                        let codeOperators = operatorsList?["code"] as? String


                                        var payment = Operations(name: name!, details: [Details](), code: code!, nameOperators: nameOperators)
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
                        return PaymentOption(id: card.id, name: card.name, type: .paymentOption, sum: card.balance, number: card.number, maskedNumber: card.maskedNumber, provider: card.type?.rawValue ?? "")
                    })
                    paymentOptions.append(contentsOf: options)
                }
                dispatchGroup.leave()
            }
        }))
        dispatchQueue.async(group: dispatchGroup, execute: DispatchWorkItem(block: {
            dispatchGroup.enter()
            NetworkManager.shared().getDepos { (success, deposits) in
                if success, let nonNilDeposits = deposits {
                    let options = nonNilDeposits.compactMap({ (deposit) -> PaymentOption? in
                        return PaymentOption(id: deposit.id, name: deposit.productName, type: .paymentOption, sum: deposit.balance, number: deposit.accountNumber, maskedNumber: deposit.accountNumber, provider: deposit.productName)
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

    func prepareCard2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeeCardNumber": destinationNumber as AnyObject,
            "payerCardNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject
        ]

        Alamofire.request(apiBaseURL + "/rest/prepareCard2Card", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
                        completionHandler(true, token)
                    } else {
                        print("rest/prepareCard2Card cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil)
                    }

                case .failure(let error):
                    print("rest/prepareCard2Card \(error)")
                    completionHandler(false, nil)
                }
        }
    }

    func prepareCard2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void) {
        let headers = NetworkManager.shared().headers
        let parameters: [String: AnyObject] = [
            "payeePhone": destinationNumber as AnyObject,
            "payerCardNumber": sourceNumber as AnyObject,
            "amount": amount as AnyObject
        ]

        Alamofire.request(apiBaseURL + "/rest/prepareCard2Phone", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String,
                    result == "ERROR" {
                    print("errorMessage")
                    completionHandler(false, nil)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let token = json["result"] as? String {
                        completionHandler(true, token)
                    } else {
                        print("rest/prepareCard2Phone cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil)
                    }

                case .failure(let error):
                    print("rest/prepareCard2Phone \(error)")
                    completionHandler(false, nil)
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

        Alamofire.request(apiBaseURL + "/rest/makeCard2Card", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
                    if let json = response.result.value as? Dictionary<String, Any>, let result = json["result"] as? String {
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
