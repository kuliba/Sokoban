/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Mapper

enum CardType: String {
    case mastercard = "card_mastercard"
    case visaGold = "card_visa_gold"
    case visaPlatinum = "card_visa_platinum"
    case visaDebet = "card_visa_debet"
}

class Card: Mappable, IProduct {
    var name: String
    var product: String
    var balance: Double
    var number: String
    var maskedNumber: String
    var id: Double
    var status: String
    var blocked: Bool
    var holderName: String

    var type: CardType?
    var paypass: Bool?
    var miniStatement: String?
    var customName: String?
    var validityPeriod: String?
    var startDate: String?
    var expirationDate: String?
    var blockedMoney: Double?
    var updatingDate: Date?
    var tariff: String?
    var branch: String?

    func getProductAbout() -> Array<AboutItem> {
//        guard let end = expirationDate else {
//            return []
//            AboutItem(title: "Окончание действия карты", value: end),
//        }
        //let blStr = String(describing: blockedMoney!)
//        AboutItem(title: "Заблокированные средства", value: blStr),
        return [
            AboutItem(title: "Доступный остаток", value: "\(balance)"),

            AboutItem(title: "Тариф", value: name)]
    }

    required init(map: Mapper) throws {
        try number = map.from("number")
        try name = map.from("name")
        try product = map.from("product")
        try balance = map.from("balance")
        try id = map.from("cardID")
        try status = map.from("status")
        try holderName = map.from("holderName")
        var mskd = ""
        if number.count > 0 {
            mskd = String(number.prefix(6))
            mskd.append(contentsOf: number.suffix(4))
            mskd.insert(contentsOf: " ", at: number.index(number.startIndex, offsetBy: 4))
            mskd.insert(contentsOf: "XX XXXX ", at: number.index(number.startIndex, offsetBy: 7))
            self.maskedNumber = mskd
        }
        try maskedNumber = map.from("numberMasked") ?? mskd

        if product.range(of: "mastercard", options: .caseInsensitive) != nil {
            type = CardType.mastercard
        } else if product.range(of: "visa", options: .caseInsensitive) != nil {
            type = CardType.visaDebet
        }

        if status.range(of: "Действует", options: .caseInsensitive) != nil {
            blocked = false
        } else {
            blocked = true
        }
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        return "<title = \(String(describing: name)), blocked = \(String(describing: blocked)), number = \(String(describing: number)), type = \(String(describing: type?.rawValue))>"
    }
}

