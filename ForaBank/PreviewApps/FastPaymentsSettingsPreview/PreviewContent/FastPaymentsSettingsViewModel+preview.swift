//
//  FastPaymentsSettingsViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import UserAccountNavigationComponent

extension FastPaymentsSettingsViewModel {
    
    static var preview: FastPaymentsSettingsViewModel {
        
        let reducer = FastPaymentsSettingsReducer.preview
        let effectHandler = FastPaymentsSettingsEffectHandler.preview
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}
