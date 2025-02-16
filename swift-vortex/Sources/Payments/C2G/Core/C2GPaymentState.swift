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
    
    public var digest: Digest? {
        
        guard termsCheck else { return nil }
        
        return productSelect.selected.map {
            
            return .init(productID: $0.digestProductID, uin: uin)
        }
    }
    
    public struct Digest: Equatable {
        
        public let productID: ProductID
        public let uin: String
        
        public init(
            productID: ProductID,
            uin: String
        ) {
            self.productID = productID
            self.uin = uin
        }
        
        public struct ProductID: Equatable {
            
            public let id: Int
            public let type: ProductType
            
            public init(
                id: Int,
                type: ProductType
            ) {
                self.id = id
                self.type = type
            }
            
            public enum ProductType: Equatable {
                
                case account, card
            }
        }
    }
}

private extension ProductSelect.Product {
    
    var digestProductID: C2GPaymentState.Digest.ProductID {
        
        switch type {
        case .account: return .init(id: id.rawValue, type: .account)
        case .card:    return .init(id: id.rawValue, type: .card)
        }
    }
}
