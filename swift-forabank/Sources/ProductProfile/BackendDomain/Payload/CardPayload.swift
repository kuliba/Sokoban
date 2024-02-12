//
//  CardPayload.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import Tagged

public extension Payload {
    
    struct CardPayload: Encodable {
        
        public typealias CardID = Tagged<_CardID, Int>
        public enum _CardID {}

        public typealias CardNumber = Tagged<_CardNumber, String>
        public enum _CardNumber {}

        public let cardId: CardID
        public let cardNumber: CardNumber?
        
        public init(cardId: CardID, cardNumber: CardNumber?) {
            self.cardId = cardId
            self.cardNumber = cardNumber
        }
    }
}

extension Payload.CardPayload {
    
    var httpBody: Data {
        
        get throws {
            
            var parameters: [String: Any] = [
                "cardID": self.cardId.rawValue
            ]

            cardNumber.map {
                parameters["cardNumber"] = $0.rawValue
            }
            
            return try JSONSerialization.data(withJSONObject: parameters as [String: Any])
        }
    }
}
