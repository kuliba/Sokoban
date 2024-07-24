//
//  ProductProfileServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 29.06.2024.
//

import Foundation
import LandingUIComponent
import LandingMapping

struct ProductProfileServices {
    
    let createBlockCardService: BlockCardServices
    let createUnblockCardService: UnblockCardServices
    let createUserVisibilityProductsSettingsService: UserVisibilityProductsSettingsServices
    let createCreateGetSVCardLimits: GetSVCardLimitsServices
    let createChangeSVCardLimit: ChangeSVCardLimitServices
    let createSVCardLanding: SVCardLandingServices

    let makeSVCardLandingViewModel: (Landing, ListHorizontalRectangleLimitsViewModel?, UILanding.Component.Config, @escaping (LandingEvent) -> Void
    ) -> LandingWrapperViewModel?
    
    let makeInformer: (String) -> Void
}

// MARK: - Preview Content

extension ProductProfileServices {
    
    static let preview: Self = .init(
        createBlockCardService: .preview(),
        createUnblockCardService: .preview(),
        createUserVisibilityProductsSettingsService: .preview(),
        createCreateGetSVCardLimits: .preview(),
        createChangeSVCardLimit: .preview(),
        createSVCardLanding: .preview(),
        makeSVCardLandingViewModel: { _,_,_,_  in nil },
        makeInformer: { _ in }
    )
}
