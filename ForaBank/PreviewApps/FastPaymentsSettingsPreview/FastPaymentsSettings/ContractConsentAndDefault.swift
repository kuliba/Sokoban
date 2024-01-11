//
//  ContractConsentAndDefault.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

enum ContractConsentAndDefault: Equatable {
    
    case active(ContractDetails)
    case inactive(ContractDetails)
    case missingContract(ConsentResult)
    case serverError(String)
    case connectivityError
}

extension ContractConsentAndDefault {
    
    struct ContractDetails: Equatable {
        
        let contract: Contract
        let consentResult: ConsentResult
        let bankDefault: BankDefault
    }
    
    struct Contract: Equatable {}
    
    typealias ConsentResult = Result<ConsentList, ConsentError>
    
    struct ConsentList: Equatable {}
    struct ConsentError: Error, Equatable {}
    
    enum BankDefault: Equatable {
        
        case onDisabled
        case offEnabled
        case offDisabled
    }
}
