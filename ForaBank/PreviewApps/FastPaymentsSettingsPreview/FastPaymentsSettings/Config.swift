//
//  Config.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

struct FastPaymentsSettingsConfig {
    
    let productSelectConfig: ProductSelectConfig
}

extension FastPaymentsSettingsConfig {
    
    var activeContractConfig: ActiveContractConfig {
        
        .init(
            productSelectConfig: productSelectConfig
        )
    }
    
    var inactiveContractConfig: InactiveContractConfig {
        
        .init()
    }
}
