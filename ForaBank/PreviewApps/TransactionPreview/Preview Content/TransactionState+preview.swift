//
//  TransactionState+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

extension TransactionState {
    
    static var preview: Self {
        
        return .init(payment: 0, isValid: true)
    }
}
