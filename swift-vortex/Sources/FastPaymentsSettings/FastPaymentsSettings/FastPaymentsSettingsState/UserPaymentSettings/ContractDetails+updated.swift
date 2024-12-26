//
//  Details+updated.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

public extension UserPaymentSettings.Details {
    
    func updated(
        paymentContract: UserPaymentSettings.PaymentContract? = nil,
        consentList: ConsentListState? = nil,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse? = nil,
        productSelector: UserPaymentSettings.ProductSelector? = nil
    ) -> Self {
        
        .init(
            paymentContract: paymentContract ?? self.paymentContract,
            consentList: consentList ?? self.consentList,
            bankDefaultResponse: bankDefaultResponse ?? self.bankDefaultResponse,
            productSelector: productSelector ?? self.productSelector
        )
    }
}
