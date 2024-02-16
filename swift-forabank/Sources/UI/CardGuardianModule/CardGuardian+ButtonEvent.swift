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
        case changePin(Card)
        case toggleVisibilityOnMain(Product)
    }
}

private extension CardGuardianEvent {
    
    typealias ButtonEvent = CardGuardian.ButtonEvent
    
    init(
        _ buttonEvent: ButtonEvent
    ) {
        
        switch buttonEvent {
        case let .toggleLock(card):
            self = .buttonTapped(.toggleLock(card))
        case let .changePin(card):
            self = .buttonTapped(.changePin(card))
        case let .toggleVisibilityOnMain(card):
            self = .buttonTapped(.toggleVisibilityOnMain(card))
        }
    }
}
