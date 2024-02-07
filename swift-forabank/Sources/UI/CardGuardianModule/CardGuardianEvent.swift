//
//  CardGuardianEvent.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import Combine

public enum CardGuardianEvent: Equatable {
    
    public static func == (lhs: CardGuardianEvent, rhs: CardGuardianEvent) -> Bool {
        switch (lhs, rhs) {
            
        case (.appear, .appear):
            return true
        case (.buttonTapped,.buttonTapped):
            return true
            
        default:
            return false
        }
    }
    
    
    case appear(CardGuardianViewModel, AnyCancellable)
    case buttonTapped(CardGuardian.ButtonTapped)
}
