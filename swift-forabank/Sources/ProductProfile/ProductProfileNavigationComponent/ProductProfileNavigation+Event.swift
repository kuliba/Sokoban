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
        
        case closeAlert(CloseType)
        case create
        case open(CardGuardianRoute)
        case cardGuardianInput(CardGuardianStateProjection)
        case dismissDestination
        case showAlert(AlertModelOf<ProductProfileNavigation.Event>)
        case onMain(Bool)
        case action(ActionType)
        
        public typealias CardGuardianRoute = GenericRoute<CardGuardianViewModel, Never, Never, Never>
    }
}

public extension ProductProfileNavigation.Event {
    
    enum CloseType {
        
        case close
        case changePin
        case lockCard
        case unlockCard
        case showСontacts
    }
}

public extension ProductProfileNavigation.Event {
    
    enum ActionType {
        
        case showOnMain
        case hideOnMain
        case changePin
        case lockCard
        case unlockCard
        case showСontacts
    }
}

