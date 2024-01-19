//
//  FastPaymentsSettingsReducer+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings

extension FastPaymentsSettingsReducer {
    
    static let preview: FastPaymentsSettingsReducer = .init(
        getProducts: { .preview }
    )
}
