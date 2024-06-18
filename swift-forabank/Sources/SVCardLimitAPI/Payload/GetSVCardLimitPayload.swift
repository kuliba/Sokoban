//
//  GetSVCardLimitPayload.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import Foundation

public struct GetSVCardLimitPayload: Equatable {

    public let cardId: Int
    
    public init(cardId: Int) {
        self.cardId = cardId
    }
}
