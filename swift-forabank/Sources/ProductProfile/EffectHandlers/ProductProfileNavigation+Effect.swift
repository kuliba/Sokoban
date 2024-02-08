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
        
        public typealias CardGuardianRoute = GenericRoute<CardGuardianViewModel, Never, Never, Never>

        case create
        case delayAlert(AlertModelOf<ProductProfileNavigation.Event>)
    }
}
