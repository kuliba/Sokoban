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
    let validityPeriod: String?
    var blocked: Bool?
    
    let startDate: Date?
    let expirationDate: Date?
    let availableBalance: Double?
    let blockedMoney: Double?
    let updatingDate: Date?
    let tariff: String?
    let id: String?
    let branch: String?
    init(type: CardType? = nil, paypass: Bool? = nil, title: String? = nil, customName: String? = nil, number: String? = nil, blocked: Bool? = nil, startDate: Date? = nil, expirationDate: Date? = nil, availableBalance: Double? = nil, blockedMoney: Double? = nil, updatingDate: Date? = nil, tariff: String? = nil, id: String? = nil, branch: String? = nil, miniStatement: String? = nil, maskedNumber: String? = nil) {
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
        self.blockedMoney = blockedMoney
        self.updatingDate = updatingDate
        self.tariff = tariff
        self.id = id
        self.branch = branch
        
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
        
        if let expirationDate = expirationDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yy"
            validityPeriod = formatter.string(from: expirationDate)
        } else {
            self.validityPeriod = nil
        }
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        return "<title = \(String(describing: title)), blocked = \(String(describing: blocked)), number = \(String(describing: number)), type = \(String(describing: type?.rawValue))>"
    }
}

