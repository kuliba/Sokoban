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

    let makeSVCardLandingViewModel: (Landing, UILanding.Component.Config, @escaping (LandingEvent.Card) -> () -> Void
    ) -> LandingWrapperViewModel?
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
        makeSVCardLandingViewModel: { _,_,_ in nil }
    )
}
