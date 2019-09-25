/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Mapper

class Account: Mappable, IProduct {
    var name: String {
        get {
            productName
        }
    }

    var maskedNumber: String {
        get {
            return number
        }
    }

    var id: Double
    var productName: String
    var productId: Int
    var currencyCode: String
    var balance: Double
    var accountNumber: String
    var number: String {
        get {
            accountNumber
        }
    }

    var ownerAgentBrief: String?
    var customName: String?
    var blocked: Bool?
    var depositorBrief: String?
    var balanceCUR: Double?
    var accountID: String?
    var availableBalance: Double?
    var branch: String?

    required init(map: Mapper) throws {
        try productName = map.from("depositProductName")
        try productId = map.from("depositProductID")
        try balance = map.from("balance")
        try accountNumber = map.from("accountNumber")
        try currencyCode = map.from("currencyCode")
        try id = map.from("depositID")
    }

    func getProductAbout() -> Array<AboutItem> {
        return [AboutItem(title: "Доступно для снятия", value: "\(balance) \(currencyCode)")]
    }
}
