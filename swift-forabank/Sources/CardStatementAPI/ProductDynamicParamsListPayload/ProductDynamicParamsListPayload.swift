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
    
    public init(productList: [ListItem]) {
        self.productList = productList
    }
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
        
        case account = "ACCOUNT"
        case card = "CARD"
        case deposit = "DEPOSIT"
        case loan = "LOAN"
    }
}

public extension ProductDynamicParamsListPayload {
    
    var httpBody: Data {
        
        get throws {
            
            let dict: [[String: Any]] = productList.map {
                [
                    "id": $0.productId.rawValue,
                    "type": $0.type.rawValue
                ]
            }
            let parameters: [String: [[String: Any]]] = [
                "productList": dict
            ]
            
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: [[String: Any]]]
            )
        }
    }
}
