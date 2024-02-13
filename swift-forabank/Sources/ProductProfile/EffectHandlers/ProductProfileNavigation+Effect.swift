//
//  ProductProfileNavigation+Effect.swift
//
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import CardGuardianModule
import UIPrimitives

public extension ProductProfileNavigation {
    
    enum Effect: Equatable {
        
        case create
        case delayAlert(AlertModelOf<ProductProfileNavigation.Event>)
        case action(ActionType)
    }
}

public extension ProductProfileNavigation.Effect {
    
    enum ActionType: Equatable {
        
        case lockCard
        case unlockCard
        case changePin
        case showOnMain(Bool)
        case showСontacts
    }
}
