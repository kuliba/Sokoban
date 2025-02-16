//
//  C2GPaymentState.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import PaymentComponents

public struct C2GPaymentState: Equatable {
    
    public var productSelect: ProductSelect
    public var termsCheck: Bool
    public let uin: String // et al other constant fields
    public let url: URL
    
    public init(
        productSelect: ProductSelect,
        termsCheck: Bool,
        uin: String,
        url: URL
    ) {
        self.productSelect = productSelect
        self.termsCheck = termsCheck
        self.uin = uin
        self.url = url
    }
}

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
