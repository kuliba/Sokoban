//
//  ActiveContractConfig.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public struct ActiveContractConfig {
    
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
