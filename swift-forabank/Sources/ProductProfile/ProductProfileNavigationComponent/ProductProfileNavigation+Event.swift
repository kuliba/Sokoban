//
//  ProductProfileNavigation+Event.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import ProductProfileComponents

public extension ProductProfileNavigation {
    
    typealias CardGuardianRoute = GenericRoute<CardGuardianViewModel, Never, Never, Never>

    typealias TopUpCardRoute = GenericRoute<TopUpCardViewModel, Never, Never, Never>
    
    typealias AccountInfoRoute = GenericRoute<AccountInfoPanelViewModel, Never, Never, Never>
    
    typealias ProductDetailsRoute = GenericRoute<ProductDetailsViewModel, Never, Never, Never>

    typealias ProductDetailsSheetRoute = GenericRoute<ProductDetailsSheetViewModel, Never, Never, Never>

    indirect enum Event: Equatable {
        
        case closeAlert
        case create(PanelKind)
        case open(Panel)
        case cardGuardianInput(CardGuardianStateProjection)
        case topUpCardInput(TopUpCardStateProjection)
        case accountInfoPanelInput(AccountInfoPanelStateProjection)
        case productDetailsInput(ProductDetailsStateProjection)
        case productDetailsSheetInput(ProductDetailsSheetStateProjection)

        case dismissModal
        case dismissDestination

        case showAlert(AlertModelOf<ProductProfileNavigation.Event>)
        
        case productProfile(ProductProfileEvent)
    }
    
    enum Panel: Equatable {
        
        case accountInfoPanelRoute(AccountInfoRoute)
        case cardGuardianRoute(CardGuardianRoute)
        case topUpCardRoute(TopUpCardRoute)
        case productDetailsRoute(ProductDetailsRoute)
        case productDetailsSheetRoute(ProductDetailsSheetRoute)
    }
}
