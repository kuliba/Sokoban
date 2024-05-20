//
//  TransactionViewModel+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

extension TransactionViewModel {
    
    static func preview(
        initialState: TransactionState = .preview
    ) -> Self {
        
        return .init(
            initialState: initialState,
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
}
