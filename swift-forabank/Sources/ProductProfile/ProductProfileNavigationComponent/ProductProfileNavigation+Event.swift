//
//  ProductProfileNavigation+Event.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import CardGuardianModule
import ActivateSlider

public extension ProductProfileNavigation {
    
    typealias CardGuardianRoute = GenericRoute<CardGuardianViewModel, Never, Never, Never>

    indirect enum Event: Equatable {
        
        case closeAlert
        case create
        case open(CardGuardianRoute)
        case cardGuardianInput(CardGuardianStateProjection)
        case dismissDestination
        case showAlert(AlertModelOf<ProductProfileNavigation.Event>)
        
        case productProfile(ProductProfileEvent)
        
        case card(ActivateSlider.Event)
    }
}
