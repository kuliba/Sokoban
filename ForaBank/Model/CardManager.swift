//
//  CardManager.swift
//  ForaBank
//
//  Created by Sergey on 16/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

class CardManager {
    // MARK: - Properties
    
    private static var sharedCardManager: CardManager = {
        let cardManager = CardManager()
        
        // Configuration
        // ...
        
        return cardManager
    }()
    
    // MARK: -
    var cards: [Card] = {
        var c1 = Card.init(type: CardType.visaGold, paypass: true, title: "Visa Gold Cashback", number: "2345 4567 8907 9706", validityPeriod: "08/18", cash: "21 350 ₽", blocked: false)
        var c2 = Card.init(type: CardType.visaPlatinum, paypass: true, title: "Visa Platinum Cashback", number: "5676 4567 8907 9706", validityPeriod: "08/18", cash: "19 500 ₽", blocked: false)
        var c3 = Card.init(type: .mastercard, paypass: false, title: "RIO CARD", number: "5009 4567 8907 9706", validityPeriod: "05/19", cash: "7500,15 ₽", blocked: false)
        var c4 = Card.init(type: .visaDebet, paypass: false, title: "Дебетовая", number: "5676 4567 8907 9706", validityPeriod: "03/21", cash: "7500,15 ₽", blocked: false)
        return [c1,c2,c3,c4]
    }()
    
    var hasBlockedCard: Bool = false//true
    
    // Initialization
    
    private init() {
    }
    
    // MARK: - Accessors
    
    class func shared() -> CardManager {
        return sharedCardManager
    }
    
    func blockCard(withNumber num: String) {
        hasBlockedCard = true
        for i in 0..<cards.count {
            if cards[i].number == num {
                cards[i].blocked = true
            }
        }
    }
}
