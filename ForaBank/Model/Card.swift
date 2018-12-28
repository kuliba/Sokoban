//
//  Card.swift
//  ForaBank
//
//  Created by Sergey on 16/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

enum CardType: String {
    case mastercard = "card_mastercard"
    case visaGold = "card_visa_gold"
    case visaPlatinum = "card_visa_platinum"
    case visaDebet = "card_visa_debet"
}

//it's class(not struct) because Card objects pass between controllers with state changes
//specific case: the card is blocked in the DepositsCardsListOnholdBlockViewController and on returning to the previous DepositsCardsListViewController its display should change
class Card {
    let type: CardType
    let paypass: Bool
    let title: String
    let number: String
    let validityPeriod: String
    var blocked: Bool
    
    let startDate: Date
    let expirationDate: Date
    let availableBalance: Double
    let blockedMoney: Double
    let updatingDate: Date
    let tariff: String
    init(type: CardType, paypass: Bool, title: String, number: String, blocked: Bool, startDate: Date, expirationDate: Date, availableBalance: Double, blockedMoney: Double, updatingDate: Date, tariff: String) {
        self.type = type
        self.paypass = paypass
        self.title = title
        self.number = number
        self.blocked = blocked
        self.startDate = startDate
        self.expirationDate = expirationDate
        self.availableBalance = availableBalance
        self.blockedMoney = blockedMoney
        self.updatingDate = updatingDate
        self.tariff = tariff
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        validityPeriod = formatter.string(from: expirationDate)
        
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        return "<title = \(title), blocked = \(blocked), number = \(number), type = \(type.rawValue)>"
    }
}
