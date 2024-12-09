//
//  UserPaymentSettings+Details.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import Tagged

public extension UserPaymentSettings {
    
    struct Details: Equatable {
        
        public var paymentContract: PaymentContract
        public var consentList: ConsentListState
        public var bankDefaultResponse: GetBankDefaultResponse
        public var productSelector: ProductSelector
        
        public init(
            paymentContract: PaymentContract,
            consentList: ConsentListState,
            bankDefaultResponse: GetBankDefaultResponse,
            productSelector: ProductSelector
        ) {
            self.paymentContract = paymentContract
            self.consentList = consentList
            self.bankDefaultResponse = bankDefaultResponse
            self.productSelector = productSelector
        }
    }
}
