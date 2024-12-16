//
//  ProductProfileNavigation+Effect.swift
//
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import CardGuardianUI
import UIPrimitives
import Foundation

public extension ProductProfileNavigation {
    
    enum Effect: Equatable {
        
        case create(PanelKind)
        case delayAlert(AlertModelOf<ProductProfileNavigation.Event>, DispatchTimeInterval)
        case productProfile(ProductProfileEffect)
    }
}
