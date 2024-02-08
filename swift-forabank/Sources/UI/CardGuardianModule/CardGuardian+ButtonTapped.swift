//
//  CardGuardian+ButtonTapped.swift
//
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import Foundation

public extension CardGuardian {
    
    enum ButtonTapped: Equatable, Hashable {
        
        case toggleLock(CardGuardianStatus)
        case changePin
        case showOnMain
        
        var event: CardGuardianEvent {
            
            switch self {
            case let .toggleLock(status):
                return .buttonTapped(.toggleLock(status))
            case .changePin:
                return .buttonTapped(.changePin)
            case .showOnMain:
                return .buttonTapped(.showOnMain)
            }
        }
    }
}
