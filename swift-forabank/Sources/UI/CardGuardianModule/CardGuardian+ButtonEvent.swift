//
//  CardGuardian+ButtonEvent.swift
//
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import Foundation

public extension CardGuardian {
    
    enum ButtonEvent: Equatable, Hashable {
        
        case toggleLock(Card)
        case changePin
        case showOnMain(Bool)
    }
}

private extension CardGuardianEvent {
    
    typealias ButtonEvent = CardGuardian.ButtonEvent
    
    init(
        _ buttonEvent: ButtonEvent
    ) {
        
        switch buttonEvent {
        case let .toggleLock(status):
            self = .buttonTapped(.toggleLock(status))
        case .changePin:
            self = .buttonTapped(.changePin)
        case let .showOnMain(status):
            self = .buttonTapped(.showOnMain(status))
        }
    }
}
