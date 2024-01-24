//
//  ProductDynamicParamsListPayload.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation
import Tagged

public struct ProductDynamicParamsListPayload: Equatable {
    
    public let productList: [ListItem]
}

extension ProductDynamicParamsListPayload {
    
    public struct ListItem: Equatable {
        
        public let productId: ProductID
        public let type: ProductType
        
        public typealias ProductID = Tagged<_ProductID, Int>
        public enum _ProductID {}
        
        public init(productId: ProductID, type: ProductType) {
            self.productId = productId
            self.type = type
        }
    }
}

extension ProductDynamicParamsListPayload {
    
    public enum ProductType: String {
        
        case card = "CARD"
        case account = "ACCOUNT"
        case loan = "LOAN"
        case deposit = "DEPOSIT"
    }
}

public extension ProductDynamicParamsListPayload {
    
    var httpBody: Data {
        
        get throws {
            
            let dict: [Any] = productList.map {
                [
                    "id": $0.productId.rawValue,
                    "type": $0.type.rawValue
                ]
            }
            var parameters: [String: Any] = [
                "productList": dict
            ]
            
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}
