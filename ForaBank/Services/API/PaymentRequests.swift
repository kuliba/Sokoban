//
//  PaymentRequests.swift
//  ForaBank
//
//  Created by Бойко Владимир on 19/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

func allPaymentOptions(completionHandler: @escaping (Bool, [PaymentOption]?) -> Void) {
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "com.payment.options")

    var paymentOptions: Array<PaymentOption> = []

    dispatchQueue.async(group: dispatchGroup, execute: DispatchWorkItem(block: {
        dispatchGroup.enter()
        NetworkManager.shared().getCardList { (success, cards) in
            if success, let nonNilCards = cards {
                let options = nonNilCards.compactMap({ (card) -> PaymentOption? in
                    guard let number = card.number, let balance = card.availableBalance else { return nil }
                    return PaymentOption(type: .card, sum: balance, number: number, provider: card.type!.rawValue)
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
                    guard let number = deposit.number, let balance = deposit.availableBalance else { return nil }
                    return PaymentOption(type: .safeDeposit, sum: balance, number: number, provider: deposit.productName)
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
