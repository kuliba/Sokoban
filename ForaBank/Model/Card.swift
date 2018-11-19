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

struct Card {
    let type: CardType
    let paypass: Bool
    let title: String
    let number: String
    let validityPeriod: String
    let cash: String
    var blocked: Bool
}
