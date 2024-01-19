//
//  FastPaymentsSettingsEffectHandler+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings

extension FastPaymentsSettingsEffectHandler {
    
    static let preview: FastPaymentsSettingsEffectHandler = .init(
        createContract: { _, completion in completion(.success(.active)) },
        getSettings: { $0(.active()) },
        prepareSetBankDefault: { $0(.success(())) },
        updateContract: { _, completion in completion(.success(.active)) },
        updateProduct: { _, completion in completion(.success(())) }
    )
}
