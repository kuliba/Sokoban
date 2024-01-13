//
//  UserPaymentSettings+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension UserPaymentSettings {
    
    static func active(
        _ consentResult: UserPaymentSettings.ConsentResult = .success,
        bankDefault: UserPaymentSettings.BankDefault = .offEnabled
    ) -> Self {
        
        .contracted(
            .preview(
                paymentContract: .active,
                consentResult: consentResult,
                bankDefault: bankDefault
            )
        )
    }
    
    static func inactive(
        _ consentResult: UserPaymentSettings.ConsentResult = .success,
        _ bankDefault: UserPaymentSettings.BankDefault = .offEnabled
    ) -> Self {
        
        .contracted(
            .preview(
                paymentContract: .inactive,
                consentResult: consentResult,
                bankDefault: bankDefault
            )
        )
    }
    
    static func missingContract(
        consent: UserPaymentSettings.ConsentResult = .success
    ) -> Self {
        
        .missingContract(consent)
    }
}

extension UserPaymentSettings.ContractDetails {
    
    static func preview(
        paymentContract: UserPaymentSettings.PaymentContract = .active,
        consentResult: UserPaymentSettings.ConsentResult = .success,
        bankDefault: UserPaymentSettings.BankDefault = .offEnabled
    ) -> Self {
        
        .init(
            paymentContract: paymentContract,
            consentResult: consentResult,
            bankDefault: bankDefault
        )
    }
}

extension UserPaymentSettings.PaymentContract {
    
    static let active: Self = .init(contractStatus: .active)
    static let inactive: Self = .init(contractStatus: .inactive)
}

private extension UserPaymentSettings.ConsentResult {
    
    static let success: Self = .success(.preview)
    static let failure: Self = .failure(.init())
}

private extension UserPaymentSettings.ConsentList {
    
    static let preview: Self = .init()
}
