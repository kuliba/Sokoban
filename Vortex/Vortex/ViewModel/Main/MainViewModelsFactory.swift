//
//  MainViewModelsFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 23.01.2025.
//

import Foundation
import CalendarUI

typealias MakeProductProfileViewModel = (ProductData, String, FilterState, @escaping () -> Void) -> ProductProfileViewModel?
typealias MakeModelAuthLoginViewModelFactory = (Model, RootViewModel.RootActions) -> ModelAuthLoginViewModelFactory
typealias MakePromoProductViewModel = (PromoItem, PromoProductActions) -> AdditionalProductViewModel?

struct PromoProductActions {
    
    let hide: () -> Void
    let show: () -> Void
}

struct MainViewModelsFactory {
    
    let makeAuthFactory: MakeModelAuthLoginViewModelFactory
    let makeProductProfileViewModel: MakeProductProfileViewModel
    let makePromoProductViewModel: MakePromoProductViewModel
    let qrViewModelFactory: QRViewModelFactory
    let makeTrailingToolbarItems: MakeTrailingToolbarItems
    let makeCreditCardMVP: MakeCreditCardMVP
    let makeAuthProductsViewModel: MakeAuthProductsViewModel // improve name typealias
    
    typealias MakeTrailingToolbarItems = (@escaping (MainViewModelAction.Toolbar) -> Void) -> [NavigationBarButtonViewModel]
    
    typealias MakeCreditCardMVP = () -> PromoItem?
    
    typealias MakeAuthProductsViewModel = (@escaping () -> Void) -> AuthProductsLandingDomain.Binder // improve name typealias
}

extension MainViewModelsFactory {
    
    static let preview: Self = .init(
        makeAuthFactory: { ModelAuthLoginViewModelFactory(model: $0, rootActions: $1) },
        makeProductProfileViewModel: ProductProfileViewModel.makeProductProfileViewModel,
        makePromoProductViewModel: {_,_ in return nil },
        qrViewModelFactory: .preview(),
        makeTrailingToolbarItems: { _ in [] },
        makeCreditCardMVP: { nil },
        makeAuthProductsViewModel: { _ in .preview }
    )
}

extension AuthProductsLandingDomain.Binder {
    
    static let preview: AuthProductsLandingDomain.Binder = .init(
        content: .mockData,
        flow: .init(
            initialState: .init(),
            reduce: { state,_ in (state, nil) },
            handleEffect: { _,_ in }
        ),
        bind: { _,_ in .init() }
    )
}
