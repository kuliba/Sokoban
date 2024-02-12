//
//  Config.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public struct FastPaymentsSettingsConfig {
    
    let bankDefault: BankDefaultConfig
    let paymentContract: PaymentContractConfig
    public let productSelect: ProductSelectConfig
    
    public init(
        bankDefault: BankDefaultConfig, 
        paymentContract: PaymentContractConfig,
        productSelect: ProductSelectConfig
    ) {
        self.bankDefault = bankDefault
        self.paymentContract = paymentContract
        self.productSelect = productSelect
    }
}

public extension FastPaymentsSettingsConfig {
    
    var activeContract: ActiveContractConfig {
        
        .init(
            bankDefault: bankDefault,
            paymentContract: paymentContract,
            productSelect: productSelect
        )
    }
    
    var inactiveContract: InactiveContractConfig {
        
        paymentContract.inactive
    }
}
