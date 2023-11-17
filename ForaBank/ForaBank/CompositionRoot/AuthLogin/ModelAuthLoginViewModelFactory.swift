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
    
    func makeLandingViewModel(
        _ type: AbroadType,
        config: UILanding.Component.Config,
        goMain: @escaping GoMainAction,
        orderCard: @escaping OrderCardAction
    ) -> LandingWrapperViewModel {
        
        self.model.landingViewModelFactory(
            abroadType: type,
            config: config,
            goMain: goMain,
            orderCard: orderCard
        )
    }
}
