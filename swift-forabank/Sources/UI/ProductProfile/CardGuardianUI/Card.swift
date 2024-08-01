//
//  Card.swift
//  
//
//  Created by Andryusina Nataly on 14.02.2024.
//

import Foundation
import Tagged

public struct Card: Equatable, Hashable {
    
    public typealias CardID = Tagged<_CardID, Int>
    public enum _CardID {}
    
    public typealias CardNumber = Tagged<_CardNumber, String>
    public enum _CardNumber {}
    
    let cardId: CardID
    let cardNumber: CardNumber
    let cardGuardianStatus: CardGuardianStatus
    
    public init(
        cardId: CardID,
        cardNumber: CardNumber,
        cardGuardianStatus: CardGuardianStatus
    ) {
        self.cardId = cardId
        self.cardNumber = cardNumber
        self.cardGuardianStatus = cardGuardianStatus
    }
    
    public var status: CardGuardianStatus {
        return cardGuardianStatus
    }
}

