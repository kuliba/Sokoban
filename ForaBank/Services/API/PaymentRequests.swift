//
//  PaymentRequests.swift
//  ForaBank
//
//  Created by Бойко Владимир on 19/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

func allPaymentOptions(completionHandler: @escaping (Bool, [PaymentOption]?) -> Void) {
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "com.payment.options")

    var paymentOptions: Array<PaymentOption> = []

    dispatchQueue.async(group: dispatchGroup, execute: DispatchWorkItem(block: {
        dispatchGroup.enter()
        NetworkManager.shared().getCardList { (success, cards) in
            if success, let nonNilCards = cards {
                let options = nonNilCards.compactMap({ (card) -> PaymentOption? in
                    return PaymentOption(id: card.id, name: card.name, type: .card, sum: card.balance, number: card.number, maskedNumber: card.maskedNumber, provider: card.type?.rawValue ?? "")
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
                    return PaymentOption(id: deposit.id, name: deposit.productName, type: .safeDeposit, sum: deposit.balance, number: deposit.accountNumber, maskedNumber: deposit.accountNumber, provider: deposit.productName)
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

    let parameters: [String: AnyObject] = [
        "payeeCardNumber": destinationNumber as AnyObject,
        "payerCardNumber": sourceNumber as AnyObject,
        "amount": amount as AnyObject
    ]

    Alamofire.request(apiBaseURL + "/rest/prepareCard2Card", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: NetworkManager.shared().headers)
        .validate(statusCode: MultiRange(200..<300, 401..<402))
        .validate(contentType: ["application/json"])
        .responseJSON { response in

            if let json = response.result.value as? Dictionary<String, Any>,
                let errorMessage = json["errorMessage"] as? String {
                print("\(errorMessage)")
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

func makeCard2Card(completionHandler: @escaping (Bool) -> Void) {
    Alamofire.request(apiBaseURL + "/rest/makeCard2Card", method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: NetworkManager.shared().headers)
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
