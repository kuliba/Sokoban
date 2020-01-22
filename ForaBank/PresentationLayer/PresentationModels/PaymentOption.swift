//
//  PaymentOption.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

struct PaymentOption: IPickerItem, IPresentationModel {

    var title: String {
        get {
            return name
        }
    }

    var subTitle: String {
        get {
            return maskedNumber
        }
    }

    var value: Double {
        get {
            return sum
        }
    }

    var itemType: PickerItemType
    let id: Double
    var name: String
    var type: RemittanceOptionViewType
    let sum: Double
    let number: String
    var maskedNumber: String
    let provider: String?
    let productType: ProductType
    
    init(id: Double, name: String, type: PickerItemType, sum: Double, number: String, maskedNumber: String, provider: String, productType: ProductType) {
        self.id = id
        self.name = name
        self.sum = sum
        self.number = number
        self.maskedNumber = maskedNumber
        self.type = .custom
        self.provider = provider
        self.itemType = type
        self.productType = productType
    }

    init(product: IProduct) {
        id = product.id
        name = product.name ?? ""
        sum = product.balance
        number = product.number
        maskedNumber = product.maskedNumber
        provider = nil
        type = .custom

        switch product {
        case is Card, is Deposit, is Account:
            itemType = .paymentOption
            break
        default:
            itemType = .plain
            break
        }
        
        switch product {
        case is Card:
            productType = .card
            break
        case is Deposit:
            productType = .deposit
            break
        case is Account:
            productType = .account
            break
        default:
            productType = .loan
            break
        }
    }
}
