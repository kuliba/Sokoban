//
//  RootViewModelFactory+makeStickerLandingViewModel.swift
//  Vortex
//
//  Created by Andrew Kurdin on 04.02.2025.
//

import LandingUIComponent

typealias LandingWrapperViewModel = LandingUIComponent.LandingWrapperViewModel

extension RootViewModelFactory {
    
    @inlinable
    func makeStickerLandingViewModel(
        _ type: AbroadType,
        config: LandingUIComponent.UILanding.Component.Config,
        landingActions: @escaping (LandingUIComponent.LandingEvent.Sticker) -> () -> Void
    ) -> LandingWrapperViewModel {
        
        self.model.landingStickerViewModelFactory(
            abroadType: type,
            config: config,
            landingActions: landingActions
        )
    }
}
