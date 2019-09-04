/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Mapper

class Account: Mappable {
    let productName: String
    let productId: String
    let currencyCode: String
    let balance: Double
    let accountNumber: String

    var ownerAgentBrief: String?
    var customName: String?
    var number: String?
    var blocked: Bool?
    var depositorBrief: String?
    var balanceCUR: Double?
    var accountID: String?
    var availableBalance: Double?
    var id: String?
    var branch: String?

    required init(map: Mapper) throws {
        try productName = map.from("depositProductName")
        try productId = map.from("depositProductID")
        try balance = map.from("balance")
        try accountNumber = map.from("accountNumber")
        try currencyCode = map.from("currencyCode")
    }
}
