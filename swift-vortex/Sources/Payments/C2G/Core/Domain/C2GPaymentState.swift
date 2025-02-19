//
//  C2GPaymentState.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import PaymentComponents

public struct C2GPaymentState<Context> {
    
    public var productSelect: ProductSelect
    public var termsCheck: Bool
    public let uin: String
    public let context: Context
    
    public init(
        productSelect: ProductSelect,
        termsCheck: Bool,
        uin: String,
        context: Context
    ) {
        self.productSelect = productSelect
        self.termsCheck = termsCheck
        self.uin = uin
        self.context = context
    }
}

extension C2GPaymentState: Equatable where Context: Equatable {}

extension C2GPaymentState {
    
    public var digest: C2GPaymentDigest? {
        
        guard termsCheck else { return nil }
        
        return productSelect.selected.map {
            
            return .init(productID: $0.digestProductID, uin: uin)
        }
    }
}

private extension ProductSelect.Product {
    
    var digestProductID: C2GPaymentDigest.ProductID {
        
        switch type {
        case .account: return .init(id: id.rawValue, type: .account)
        case .card:    return .init(id: id.rawValue, type: .card)
        }
    }
}
