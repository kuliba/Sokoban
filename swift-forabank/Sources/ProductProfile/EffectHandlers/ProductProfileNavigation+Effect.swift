//
//  ProductProfileNavigation+Effect.swift
//
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import CardGuardianModule

public extension ProductProfileNavigation {
    
    enum Effect: Equatable {
        
        case cardGuardian(CardGuardianEvent)
    }
}
