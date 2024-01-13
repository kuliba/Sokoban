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
                consentResult: consentResult,
                bankDefault: bankDefault
            ),
            .active
        )
    }
    
    static func inactive(
        _ consentResult: UserPaymentSettings.ConsentResult = .success,
        _ bankDefault: UserPaymentSettings.BankDefault = .offEnabled
    ) -> Self {
        
        .contracted(
            .preview(
                consentResult: consentResult,
                bankDefault: bankDefault
            ),
            .inactive
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
        consentResult: UserPaymentSettings.ConsentResult = .success,
        bankDefault: UserPaymentSettings.BankDefault = .offEnabled
    ) -> Self {
        
        .init(
            paymentContract: .preview,
            consentResult: consentResult,
            bankDefault: bankDefault
        )
    }
}

private extension UserPaymentSettings.PaymentContract {
    
    static let preview: Self = .init()
}

private extension UserPaymentSettings.ConsentResult {
    
    static let success: Self = .success(.preview)
    static let failure: Self = .failure(.init())
}

private extension UserPaymentSettings.ConsentList {
    
    static let preview: Self = .init()
}
