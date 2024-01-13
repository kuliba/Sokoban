//
//  FastPaymentsSettingsReducer+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension FastPaymentsSettingsReducer {
    
    static let preview: FastPaymentsSettingsReducer = .init(
        
        getUserPaymentSettings: { $0(.active()) },
        updateContract: { _, completion in completion(.success(.active)) },
        getProduct: { .init(id: "1234567890") },
        createContract: { _, completion in completion(.success(.active)) },
        prepareSetBankDefault: { $0(.success) }
    )
}
