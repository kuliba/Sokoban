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

class Card {
    let type: CardType
    let paypass: Bool
    let title: String
    let number: String
    let validityPeriod: String
    let cash: String
    var blocked: Bool
    
    init(type: CardType, paypass: Bool, title: String, number: String, validityPeriod: String, cash: String, blocked: Bool) {
        self.type = type
        self.paypass = paypass
        self.title = title
        self.number = number
        self.validityPeriod = validityPeriod
        self.cash = cash
        self.blocked = blocked
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        return "<title = \(title), blocked = \(blocked), number = \(number), type = \(type.rawValue)>"
    }
}
