//
//  ActiveContractConfig.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent
import CarouselComponent
import SwiftUI

public struct ActiveContractConfig {
    
    let accountLinking: AccountLinkingConfig
    let backgroundColor: Color
    let bankDefault: BankDefaultConfig
    let carousel: CarouselComponentConfig
    let consentList: ConsentListConfig
    public let deleteDefaultBank: DeleteDefaultBankConfig
    let paymentContract: PaymentContractConfig
    public let productSelect: ProductSelectConfig
    
    public init(
        accountLinking: AccountLinkingConfig,
        backgroundColor: Color,
        bankDefault: BankDefaultConfig,
        carousel: CarouselComponentConfig,
        consentList: ConsentListConfig,
        deleteDefaultBank: DeleteDefaultBankConfig,
        paymentContract: PaymentContractConfig,
        productSelect: ProductSelectConfig
    ) {
        self.accountLinking = accountLinking
        self.backgroundColor = backgroundColor
        self.bankDefault = bankDefault
        self.carousel = carousel
        self.consentList = consentList
        self.deleteDefaultBank = deleteDefaultBank
        self.paymentContract = paymentContract
        self.productSelect = productSelect
    }
}
