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
        
        case delayAlert(AlertModelOf<ProductProfileNavigation.Event>)
    }
}
