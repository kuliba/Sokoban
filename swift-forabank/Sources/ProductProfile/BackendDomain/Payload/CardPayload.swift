//
//  CardPayload.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import Tagged

public extension Payloads {
    
    struct CardPayload {
        
        public typealias CardID = Tagged<_CardID, Int>
        public enum _CardID {}

        public typealias CardNumber = Tagged<_CardNumber, String>
        public enum _CardNumber {}

        public let cardId: CardID
        public let cardNumber: CardNumber
        
        public init(
            cardId: CardID,
            cardNumber: CardNumber
        ) {
            self.cardId = cardId
            self.cardNumber = cardNumber
        }
    }
}

extension Payloads.CardPayload {
    
    var httpBody: Data {
        
        get throws {
            
            return try JSONSerialization.data(withJSONObject: [
                "cardID": cardId.rawValue,
                "cardNumber": cardNumber.rawValue
            ] as [String: Any])
        }
    }
}
