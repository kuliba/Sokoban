//
//  Card.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import Tagged

public struct Card: Equatable, Hashable {
        
    let cardId: CardID
    let cardNumber: CardNumber
    let cardStatus: CardStatus
    
    public init(
        cardId: CardID,
        cardNumber: CardNumber,
        cardStatus: CardStatus
    ) {
        self.cardId = cardId
        self.cardNumber = cardNumber
        self.cardStatus = cardStatus
    }
    
    public var status: CardStatus {
        return cardStatus
    }
}

public extension Card {
    
    typealias CardID = Tagged<_CardID, Int>
    enum _CardID {}
    
    typealias CardNumber = Tagged<_CardNumber, String>
    enum _CardNumber {}
}
