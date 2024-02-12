//
//  Config.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent
import SwiftUI

public struct FastPaymentsSettingsConfig {
    
    let backgroundColor: Color
    let bankDefault: BankDefaultConfig
    let paymentContract: PaymentContractConfig
    public let productSelect: ProductSelectConfig
    
    public init(
        backgroundColor: Color,
        bankDefault: BankDefaultConfig,
        paymentContract: PaymentContractConfig,
        productSelect: ProductSelectConfig
    ) {
        self.backgroundColor = backgroundColor
        self.bankDefault = bankDefault
        self.paymentContract = paymentContract
        self.productSelect = productSelect
    }
}

public extension FastPaymentsSettingsConfig {
    
    var activeContract: ActiveContractConfig {
        
        .init(
            backgroundColor: backgroundColor,
            bankDefault: bankDefault,
            paymentContract: paymentContract,
            productSelect: productSelect
        )
    }
    
    var inactiveContract: InactiveContractConfig {
        
        paymentContract.inactive
    }
}
