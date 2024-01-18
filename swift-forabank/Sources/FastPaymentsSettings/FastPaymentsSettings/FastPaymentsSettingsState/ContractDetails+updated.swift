//
//  ContractDetails+updated.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

public extension UserPaymentSettings.ContractDetails {
    
    func updated(
        paymentContract: UserPaymentSettings.PaymentContract? = nil,
        consentResult: UserPaymentSettings.ConsentResult? = nil,
        bankDefault: UserPaymentSettings.BankDefault? = nil,
        productSelector: UserPaymentSettings.ProductSelector? = nil
    ) -> Self {
        
        .init(
            paymentContract: paymentContract ?? self.paymentContract,
            consentResult: consentResult ?? self.consentResult,
            bankDefault: bankDefault ?? self.bankDefault,
            productSelector: productSelector ?? self.productSelector
        )
    }
}
