//
//  ProductProfileNavigation+Event.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import CardGuardianModule
import Combine

public extension ProductProfileNavigation {
    
    indirect enum Event: Equatable {
        
        public static func == (lhs: ProductProfileNavigation.Event, rhs: ProductProfileNavigation.Event) -> Bool {
            switch (lhs, rhs) {
               
            case let (.openCardGuardianPanel(lhs, _),.openCardGuardianPanel(rhs, _)):
                return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
            case (.closeAlert,.closeAlert):
                return true
            case (.showAlertChangePin,.showAlertChangePin):
                return true
            case (.dismissDestination,.dismissDestination):
                return true
            case let (.showAlertCardGuardian(lhs),.showAlertCardGuardian(rhs)):
                return lhs == rhs
            case let (.showAlert(lhs),.showAlert(rhs)):
                return lhs == rhs

            default:
                return false
            }
        }
        
        case closeAlert
        case openCardGuardianPanel(CardGuardianViewModel, AnyCancellable)
        case dismissDestination
        case showAlertChangePin
        case showAlertCardGuardian(CardGuardian.CardGuardianStatus)
        case showAlert(AlertModelOf<ProductProfileNavigation.Event>)
    }
}
