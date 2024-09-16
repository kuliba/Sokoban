//
//  ModelAuthLoginViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.11.2023.
//

import Foundation
import LandingUIComponent

final class ModelAuthLoginViewModelFactory {
    
    private let model: Model
    private let rootActions: RootViewModel.RootActions
    
    init(
        model: Model,
        rootActions: RootViewModel.RootActions
    ) {
        self.model = model
        self.rootActions = rootActions
    }
    
    func makeAuthConfirmViewModel(
        confirmCodeLength: Int,
        phoneNumber: String,
        resendCodeDelay: TimeInterval,
        backAction: @escaping () -> Void
    ) -> AuthConfirmViewModel {
        
        .init(
            model,
            confirmCodeLength: confirmCodeLength,
            phoneNumber: phoneNumber,
            resendCodeDelay: resendCodeDelay,
            backAction: backAction,
            rootActions: rootActions
        )
    }
    
    func makeAuthProductsViewModel(
        action: @escaping (_ id: Int) -> Void,
        dismissAction: @escaping () -> Void
    ) -> AuthProductsViewModel {
        
        .init(
            model,
            products: model.catalogProducts.value,
            action: action,
            dismissAction: dismissAction
        )
    }
    
    func makeOrderProductViewModel(
        productData: CatalogProductData
    ) -> OrderProductView.ViewModel {
        
        .init(
            model,
            productData: productData
        )
    }
    
    func makeCardLandingViewModel(
        _ type: AbroadType,
        config: LandingUIComponent.UILanding.Component.Config,
        landingActions: @escaping (LandingUIComponent.LandingEvent.Card) -> () -> Void
    ) -> LandingUIComponent.LandingWrapperViewModel {
        
        self.model.landingCardViewModelFactory(
            abroadType: type,
            config: config,
            landingActions: landingActions
        )
    }
    
    func makeStickerLandingViewModel(
        _ type: AbroadType,
        config: LandingUIComponent.UILanding.Component.Config,
        landingActions: @escaping (LandingUIComponent.LandingEvent.Sticker) -> () -> Void
    ) -> LandingUIComponent.LandingWrapperViewModel {
            
            self.model.landingStickerViewModelFactory(
                abroadType: type,
                config: config,
                landingActions: landingActions
            )
        }
    
    func makeMarketPlaceLandingViewModel(
        _ type: String,
        config: LandingUIComponent.UILanding.Component.Config,
        landingActions: @escaping (LandingUIComponent.LandingEvent.Card) -> () -> Void
    ) -> LandingUIComponent.LandingWrapperViewModel {
        
        self.model.landingMarketplaceViewModelFactory(
            abroadType: type,
            config: config,
            landingActions: landingActions
        )
    }
}
