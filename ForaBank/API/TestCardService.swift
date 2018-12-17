//
//  TestCardService.swift
//  ForaBank
//
//  Created by Sergey on 17/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class TestCardService: CardServiceProtocol {
    
    
    private var cards: [Card] = {
        var c1 = Card.init(type: CardType.visaGold, paypass: true, title: "Visa Gold Cashback", number: "2345 4567 8907 9707", validityPeriod: "08/18", cash: "21 350 ₽", blocked: false)
        var c2 = Card.init(type: CardType.visaPlatinum, paypass: true, title: "Visa Platinum Cashback", number: "5676 4567 8907 9706", validityPeriod: "08/18", cash: "19 500 ₽", blocked: false)
        var c3 = Card.init(type: .mastercard, paypass: false, title: "RIO CARD", number: "5009 4567 8907 9705", validityPeriod: "05/19", cash: "7500,15 ₽", blocked: false)
        var c4 = Card.init(type: .visaDebet, paypass: false, title: "Дебетовая", number: "5676 4567 8907 9704", validityPeriod: "03/21", cash: "7500,15 ₽", blocked: false)
        var c5 = Card.init(type: CardType.visaPlatinum, paypass: true, title: "Visa Platinum Cashback", number: "5676 4567 8907 9703", validityPeriod: "08/18", cash: "19 500 ₽", blocked: false)
        var c6 = Card.init(type: CardType.visaGold, paypass: true, title: "Visa Gold Cashback", number: "2345 4567 8907 9702", validityPeriod: "08/18", cash: "21 350 ₽", blocked: false)
        var c7 = Card.init(type: .visaDebet, paypass: false, title: "Дебетовая", number: "5676 4567 8907 9701", validityPeriod: "03/21", cash: "7500,15 ₽", blocked: false)
        return [c1,c2,c3,c4,c5,c6,c7]
//        return []
    }()
    
    func getCardList(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Card]?) -> Void) {
        completionHandler(true, cards)
    }
    func blockCard(withNumber num: String, completionHandler: @escaping (Bool) -> Void) {
        for i in 0..<cards.count {
            if cards[i].number == num {
                cards[i].blocked = true
            }
        }
        completionHandler(true)
    }
}
