//
//  FastPaymentsSettingsConfig.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent
import SwiftUI

public struct FastPaymentsSettingsConfig {
    
    let accountLinking: AccountLinkingConfig
    let backgroundColor: Color
    let bankDefault: BankDefaultConfig
    let consentList: ConsentListConfig
    let paymentContract: PaymentContractConfig
    public let productSelect: ProductSelectConfig
    
    public init(
        accountLinking: AccountLinkingConfig,
        backgroundColor: Color,
        bankDefault: BankDefaultConfig,
        consentList: ConsentListConfig,
        paymentContract: PaymentContractConfig,
        productSelect: ProductSelectConfig
    ) {
        self.accountLinking = accountLinking
        self.backgroundColor = backgroundColor
        self.bankDefault = bankDefault
        self.consentList = consentList
        self.paymentContract = paymentContract
        self.productSelect = productSelect
    }
}

public extension FastPaymentsSettingsConfig {
    
    var activeContract: ActiveContractConfig {
        
        .init(
            accountLinking: accountLinking,
            backgroundColor: backgroundColor,
            bankDefault: bankDefault,
            consentList: consentList,
            paymentContract: paymentContract,
            productSelect: productSelect
        )
    }
    
    var inactiveContract: InactiveContractConfig {
        
        .init(
            backgroundColor: backgroundColor,
            contract: paymentContract.inactive
        )
    }
}
