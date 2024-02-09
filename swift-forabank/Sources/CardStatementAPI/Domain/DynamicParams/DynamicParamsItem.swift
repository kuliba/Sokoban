//
//  DynamicParamsItem.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct DynamicParamsItem: Equatable {
   
    public let id: Int
    public let type: ProductType
    public let dynamicParams: DynamicParams
    
    public init(id: Int, type: ProductType, dynamicParams: DynamicParams) {
        self.id = id
        self.type = type
        self.dynamicParams = dynamicParams
    }
}

extension DynamicParamsItem {
    
    public enum ProductType: Equatable {
        
        case account
        case card
        case deposit
        case loan
    }
}
