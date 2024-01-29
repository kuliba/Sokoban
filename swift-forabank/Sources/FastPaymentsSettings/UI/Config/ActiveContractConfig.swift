//
//  ActiveContractConfig.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public struct ActiveContractConfig {
    
    public let productSelect: ProductSelectConfig
    
    public init(productSelect: ProductSelectConfig) {
     
        self.productSelect = productSelect
    }
}
