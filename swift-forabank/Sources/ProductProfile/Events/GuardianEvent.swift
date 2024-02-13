//
//  GuardianEvent.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged

public enum GuardianEvent: Equatable {
    
    case blockCard(CardInfo)
    case unblockCard(CardInfo)
}

public extension GuardianEvent {
    
    struct CardInfo: Equatable {
        
        public typealias CardID = Tagged<_CardID, Int>
        public enum _CardID {}

        public typealias CardNumber = Tagged<_CardNumber, String>
        public enum _CardNumber {}

        let cardId: CardID
        let cardNumber: CardNumber
        
        public init(
            cardId: CardID,
            cardNumber: CardNumber
        ) {
            self.cardId = cardId
            self.cardNumber = cardNumber
        }
    }
}
