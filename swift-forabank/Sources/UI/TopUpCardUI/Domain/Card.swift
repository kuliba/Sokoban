//
//  Card.swift
//
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import Tagged

public struct Card: Equatable, Hashable {
    
    public typealias CardID = Tagged<_CardID, Int>
    public enum _CardID {}
    
    public typealias CardNumber = Tagged<_CardNumber, String>
    public enum _CardNumber {}
    
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
