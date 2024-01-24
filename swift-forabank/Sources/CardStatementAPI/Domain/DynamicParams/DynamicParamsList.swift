//
//  DynamicParamsList.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct DynamicParamsList {
   
    public let id: Int
    public let type: ProductType
    public let dynamicParams: [DynamicParams]
    
    public init(id: Int, type: ProductType, dynamicParams: [DynamicParams]) {
        self.id = id
        self.type = type
        self.dynamicParams = dynamicParams
    }
}

extension DynamicParamsList {
    
    public enum ProductType {
        
        case account
        case card
        case deposit
        case loan
    }
}
