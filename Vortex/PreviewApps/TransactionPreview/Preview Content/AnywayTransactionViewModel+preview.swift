//
//  AnywayTransactionViewModel+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

extension AnywayTransactionViewModel {
    
    static func preview(
        initialState: AnywayTransactionState = .preview
    ) -> Self {
        
        return .init(
            initialState: initialState,
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
}
