//
//  AnywayTransactionState+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

extension AnywayTransactionState {
    
    static var preview: Self {
        
        return .init(payment: .preview, isValid: true)
    }
}
