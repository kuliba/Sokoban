//
//  ProductProfileNavigation+Event.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import CardGuardianModule

public extension ProductProfileNavigation {
    
    indirect enum Event: Equatable {
        
        case closeAlert
        case openCardGuardianPanel
        case dismissDestination
        case showAlertChangePin
        case showAlertCardGuardian(CardGuardian.CardGuardianStatus)
        case showAlert(AlertModelOf<ProductProfileNavigation.Event>)
    }
}
