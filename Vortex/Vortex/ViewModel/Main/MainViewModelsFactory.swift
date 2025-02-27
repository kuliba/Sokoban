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
    
    typealias MakeTrailingToolbarItems = (@escaping (MainViewModelAction.Toolbar) -> Void) -> [NavigationBarButtonViewModel]
    
    typealias MakeCreditCardMVP = () -> PromoItem?
}

extension MainViewModelsFactory {
    
    static let preview: Self = .init(
        makeAuthFactory: { ModelAuthLoginViewModelFactory(model: $0, rootActions: $1) },
        makeProductProfileViewModel: ProductProfileViewModel.makeProductProfileViewModel,
        makePromoProductViewModel: {_,_ in return nil },
        qrViewModelFactory: .preview(),
        makeTrailingToolbarItems: { _ in [] },
        makeCreditCardMVP: { nil }
    )
}
