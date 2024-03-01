//
//  ProductProfileRoute.swift
//
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import CardGuardianUI
import UIPrimitives
import Foundation
import TopUpCardUI

public extension ProductProfileNavigation.State {
    
    typealias CardGuardianRoute = GenericRoute<CardGuardianViewModel, ProductProfileNavigation.State.CGDestination, Never, AlertModelOf<ProductProfileNavigation.Event>>
    
    typealias TopUpCardRoute = GenericRoute<TopUpCardViewModel, ProductProfileNavigation.State.CGDestination, Never, AlertModelOf<ProductProfileNavigation.Event>>

    
    enum ProductProfileRoute: Equatable, Identifiable {
        
        public var id: UUID {
            switch self {
           
            case let .cardGuardian(route):
                return route.id
            case let .topUpCard(route):
                return route.id
            }
        }

        case cardGuardian(CardGuardianRoute)
        case topUpCard(TopUpCardRoute)
    }
}
