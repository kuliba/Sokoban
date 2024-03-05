//
//  ProductProfileRoute.swift
//
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import ProductProfileComponents
import UIPrimitives
import Foundation

public extension ProductProfileNavigation.State {
    
    typealias CardGuardianRoute = GenericRoute<CardGuardianViewModel, ProductProfileNavigation.State.CGDestination, Never, AlertModelOf<ProductProfileNavigation.Event>>
    
    typealias TopUpCardRoute = GenericRoute<TopUpCardViewModel, ProductProfileNavigation.State.CGDestination, Never, AlertModelOf<ProductProfileNavigation.Event>>

    typealias AccountInfoRoute = GenericRoute<AccountInfoPanelViewModel, ProductProfileNavigation.State.CGDestination, Never, Never>

    
    enum ProductProfileRoute: Equatable, Identifiable {
        
        public var id: UUID {
            switch self {
           
            case let .cardGuardian(route):
                return route.id
            case let .topUpCard(route):
                return route.id
            case let .accountInfo(route):
                return route.id
            }
        }

        case accountInfo(AccountInfoRoute)
        case cardGuardian(CardGuardianRoute)
        case topUpCard(TopUpCardRoute)
    }
}
