//
//  Product.swift
//  ForaBank
//
//  Created by Бойко Владимир on 24.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Mapper

class Product: Mappable, IProduct {

    enum ProductType: String {
        case card = "CARD"
        case account = "ACCOUNT"
        case loan = "LOAN"
    }

    enum ProductStatus: String {
        case active = "Действует"
        case NOT_BLOCKED = "NOT_BLOCKED"
    }

    var id: Double {
        return 0 ///Узнавать у Крюкова
    }
    var maskedNumber: String {
        return numberMasked
    }
    var number: String
    var numberMasked: String
    var balance: Double
    var currencyCode: String
    var productType: ProductType
    var productName: String
    var ownerID: Int
    var accountNumber: String
    var allowDebit: Bool
    var allowCredit: Bool
    var cardID: Int
    var name: String
    var validThru: Int
    var status: ProductStatus
    var holderName: String
    var product: String
    var branch: String

    required init(map: Mapper) throws {
        try number = map.from("number")
        try numberMasked = map.from("numberMasked")
        try balance = map.from("balance")
        try currencyCode = map.from("currency")
        try productType = map.from("productType")
        try productName = map.from("productName")
        try ownerID = map.from("ownerID")
        try accountNumber = map.from("accountNumber")
        try allowDebit = map.from("allowDebit")
        try allowCredit = map.from("allowCredit")
        try cardID = map.from("cardID")
        try name = map.from("name")
        try validThru = map.from("validThru")
        try status = map.from("status")
        try holderName = map.from("holderName")
        try product = map.from("product")
        try branch = map.from("branch")
    }
}
