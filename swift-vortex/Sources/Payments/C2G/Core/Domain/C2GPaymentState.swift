//
//  C2GPaymentState.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import PaymentComponents

public struct C2GPaymentState<Context> {
    
    public let context: Context
    public var productSelect: ProductSelect
    public var termsCheck: Bool?
    public let uin: String
    
    public init(
        context: Context,
        productSelect: ProductSelect,
        termsCheck: Bool?,
        uin: String
    ) {
        self.context = context
        self.productSelect = productSelect
        self.termsCheck = termsCheck
        self.uin = uin
    }
}

extension C2GPaymentState: Equatable where Context: Equatable {}

extension C2GPaymentState {
    
    public var digest: C2GPaymentDigest? {
        
        guard isTermsCheckOK else { return nil }
        
        return productSelect.selected.map {
            
            return .init(product: $0, uin: uin)
        }
    }
    
    private var isTermsCheckOK: Bool {
        
        return termsCheck ?? true
    }
}
