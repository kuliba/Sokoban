//
//  FastPaymentsSettingsViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension FastPaymentsSettingsViewModel {
    
    static var preview: FastPaymentsSettingsViewModel {
        
        let reducer = FastPaymentsSettingsReducer.preview
        
        return .init(
            initialState: nil,
            reduce: reducer.reduce(_:_:_:)
        )
    }
}
