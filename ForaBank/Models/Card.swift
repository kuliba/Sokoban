/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

enum CardType: String {
    case mastercard = "card_mastercard"
    case visaGold = "card_visa_gold"
    case visaPlatinum = "card_visa_platinum"
    case visaDebet = "card_visa_debet"
}


//it's class(not struct) because Card objects pass between controllers with state changes
//specific case: the card is blocked in the DepositsCardsListOnholdBlockViewController and on returning to the previous DepositsCardsListViewController its display should change
class Card {
    let type: CardType?
    let paypass: Bool?
    let title: String?
    let miniStatement: String?
    let customName: String?
    let number: String?
    let maskedNumber: String?
    var validityPeriod: String?
    var blocked: Bool?
    let product: String
    let startDate: String?
    let expirationDate: String?
    let availableBalance: Double?
    let blockedMoney: Double?
    let updatingDate: Date?
    let tariff: String?
    let id: String?
    let branch: String?
    init(type: CardType? = nil, paypass: Bool? = nil, title: String? = nil, customName: String? = nil, number: String? = nil, blocked: Bool? = nil, startDate: String? = nil, expirationDate: String? = nil, availableBalance: Double? = nil, blockedMoney: Double? = nil, updatingDate: Date? = nil, tariff: String? = nil, id: String? = nil, branch: String? = nil, miniStatement: String? = nil, maskedNumber: String? = nil, product: String = "") {
        self.miniStatement = miniStatement
        self.type = type
        self.paypass = paypass
        self.title = title
        self.customName = customName
        self.number = number
        self.blocked = blocked
        self.startDate = startDate
        self.expirationDate = expirationDate
        self.availableBalance = availableBalance
        self.blockedMoney = blockedMoney ?? 0
        self.updatingDate = updatingDate
        self.tariff = tariff
        self.id = id
        self.branch = branch
        self.product = product

        var mskd = ""
        if let number = number,
            maskedNumber == nil {
            mskd = String(number.prefix(6))
            mskd.append(contentsOf: number.suffix(4))
            mskd.insert(contentsOf: " ", at: number.index(number.startIndex, offsetBy: 4))
            mskd.insert(contentsOf: "XX XXXX ", at: number.index(number.startIndex, offsetBy: 7))
            self.maskedNumber = mskd
        } else {
            self.maskedNumber = maskedNumber
        }
    }

    func getProductAbout() -> Array<AboutItem> {
        guard let end = expirationDate, let tar = title else {
            return []
        }
        let blStr = String(describing: blockedMoney!)
        return [AboutItem(title: "Окончание действия карты", value: end),
                AboutItem(title: "Доступный остаток", value: "\(availableBalance!)"),
                AboutItem(title: "Заблокированные средства", value: blStr),
                AboutItem(title: "Тариф", value: tar)]
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        return "<title = \(String(describing: title)), blocked = \(String(describing: blocked)), number = \(String(describing: number)), type = \(String(describing: type?.rawValue))>"
    }
}

