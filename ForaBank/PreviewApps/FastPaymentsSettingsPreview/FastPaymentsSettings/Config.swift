//
//  Config.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

struct FastPaymentsSettingsConfig {
    
    let productSelect: ProductSelectConfig
}

extension FastPaymentsSettingsConfig {
    
    var activeContract: ActiveContractConfig {
        
        .init(
            productSelect: productSelect
        )
    }
    
    var inactiveContract: InactiveContractConfig {
        
        .init()
    }
}
