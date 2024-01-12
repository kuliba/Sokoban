//
//  ContractConsentAndDefault+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension ContractConsentAndDefault {
    
    static func active(
        _ consentResult: ContractConsentAndDefault.ConsentResult = .success,
        _ bankDefault: ContractConsentAndDefault.BankDefault = .offEnabled
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
        _ consentResult: ContractConsentAndDefault.ConsentResult = .success,
        _ bankDefault: ContractConsentAndDefault.BankDefault = .offEnabled
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
        consent: ContractConsentAndDefault.ConsentResult = .success
    ) -> Self {
        
        .missingContract(consent)
    }
}

private extension ContractConsentAndDefault.ContractDetails {
    
    static func preview(
        consentResult: ContractConsentAndDefault.ConsentResult = .success,
        bankDefault: ContractConsentAndDefault.BankDefault = .offEnabled
    ) -> Self {
        
        .init(
            contract: .preview,
            consentResult: consentResult,
            bankDefault: bankDefault
        )
    }
}

private extension ContractConsentAndDefault.Contract {
    
    static let preview: Self = .init()
}

private extension ContractConsentAndDefault.ConsentResult {
    
    static let success: Self = .success(.preview)
    static let failure: Self = .failure(.init())
}

private extension ContractConsentAndDefault.ConsentList {
    
    static let preview: Self = .init()
}
