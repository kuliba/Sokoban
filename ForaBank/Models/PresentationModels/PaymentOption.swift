//
//  PaymentOption.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

struct PaymentOption {
    let id: Double
    let name: String
    let type: RemittanceOptionViewType
    let sum: Double
    let number: String
    let maskedNumber: String
    let provider: String?

    init(id: Double, name: String, type: RemittanceOptionViewType, sum: Double, number: String, maskedNumber: String, provider: String) {
        self.id = id
        self.name = name
        self.sum = sum
        self.number = number
        self.maskedNumber = maskedNumber
        self.type = type
        self.provider = provider
    }

    init(product: IProduct) {
        id = product.id
        name = product.name
        sum = product.balance
        number = product.number
        maskedNumber = product.maskedNumber
        provider = nil
        switch product {
        case is Card:
            type = .card
            break
        case is Deposit:
            type = .safeDeposit
            break
        default:
            type = .custom
            break
        }
    }
}
