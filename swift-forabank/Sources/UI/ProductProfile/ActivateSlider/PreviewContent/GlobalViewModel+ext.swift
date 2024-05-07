//
//  GlobalViewModel+ext.swift
//
//
//  Created by Andryusina Nataly on 03.05.2024.
//

import Foundation

public extension ActivateSliderViewModel {
    
    static let previewActivateSuccess = ActivateSliderViewModel(
        initialState: .initialState,
        reduce: CardActivateReducer.reduceForPreview(),
        handleEffect: CardActivateEffectHandler.handleEffectActivateSuccess()
    )
    
    static let previewActivateFailure = ActivateSliderViewModel(
        initialState: .initialState,
        reduce: CardActivateReducer.reduceForPreview(),
        handleEffect: CardActivateEffectHandler.handleEffectActivateFailure()
    )
}
