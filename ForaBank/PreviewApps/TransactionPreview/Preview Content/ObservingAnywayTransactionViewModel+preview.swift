//
//  ObservingCachedAnywayTransactionViewModel+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

extension ObservingCachedAnywayTransactionViewModel {
    
    static func preview(
        initialState: AnywayTransactionState = .preview
    ) -> Self {
        
        return .init(observable: .preview(), observe: { _ in })
    }
}
