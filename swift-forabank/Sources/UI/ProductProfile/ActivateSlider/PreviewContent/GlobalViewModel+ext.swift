//
//  GlobalViewModel+ext.swift
//
//
//  Created by Andryusina Nataly on 03.05.2024.
//

import Foundation

public extension GlobalViewModel {
    
    static let previewActivateSuccess = GlobalViewModel(
        initialState: .initialState,
        reduce: CardActivateReducer.reduceForPreview(),
        handleEffect: CardActivateEffectHandler.handleEffectActivateSuccess()
    )
    
    static let previewActivateFailure = GlobalViewModel(
        initialState: .initialState,
        reduce: CardActivateReducer.reduceForPreview(),
        handleEffect: CardActivateEffectHandler.handleEffectActivateFailure()
    )
}
