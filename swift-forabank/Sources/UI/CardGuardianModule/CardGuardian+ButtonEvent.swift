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
        case showOnMain(Product)
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
        case let .changePin(card):
            self = .buttonTapped(.changePin(card))
        case let .showOnMain(status):
            self = .buttonTapped(.showOnMain(status))
        }
    }
}
