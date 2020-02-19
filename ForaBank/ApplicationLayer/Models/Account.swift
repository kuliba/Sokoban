/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Mapper

class Account: Mappable, IProduct {
    var name: String? {
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
    var dateStart: Double
    var isClosed: Bool
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
        try dateStart = map.from("dateStart")
        try isClosed = map.from("isClosed")


    }

    func getProductAbout() -> Array<AboutItem> {
        var status: String
        print(isClosed.description)
        if isClosed.description == "true"{
            status = "Не действует"
        } else{
            status = "Дейтсвует"
        }
        let dateStartFormatter = dayMonthYear(milisecond: dateStart)
        return
            [AboutItem(title: "Номер", value: "\(accountNumber)"),
            AboutItem(title: "Договор действует с", value: "\(dateStartFormatter)"),
             AboutItem(title: "Валюта", value: "\(currencyCode)"),
             AboutItem(title: "Доступный остаток", value: "\(balance) \(currencyCode)"),
             AboutItem(title: "Состояние", value: "\(status)"),

        ]
    
    }
}
