//
//  Config.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public struct FastPaymentsSettingsConfig {
    
    public let productSelect: ProductSelectConfig
    
    public init(productSelect: ProductSelectConfig) {
     
        self.productSelect = productSelect
    }
}

public extension FastPaymentsSettingsConfig {
    
    var activeContract: ActiveContractConfig {
        
        .init(
            productSelect: productSelect
        )
    }
    
    var inactiveContract: InactiveContractConfig {
        
        .init()
    }
}
