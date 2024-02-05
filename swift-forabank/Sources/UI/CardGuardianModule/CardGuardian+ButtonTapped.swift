//
//  CardGuardian+ButtonTapped.swift
//
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import Foundation

public extension CardGuardian {
    
    enum ButtonTapped: Equatable {
        
        case toggleLock
        case changePin
        case showOnMain
        
        var event: CardGuardianEvent {
            
            switch self {
            case .toggleLock:
                return .buttonTapped(.toggleLock)
            case .changePin:
                return .buttonTapped(.changePin)
            case .showOnMain:
                return .buttonTapped(.showOnMain)
            }
        }
    }
}
