//
//  UserPaymentSettings.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

enum UserPaymentSettings: Equatable {
    
    case contracted(ContractDetails, ContractStatus)
    case missingContract(ConsentResult)
    case failure(Failure)
}

extension UserPaymentSettings {
    
    struct ContractDetails: Equatable {
        
        var paymentContract: PaymentContract
        let consentResult: ConsentResult
        let bankDefault: BankDefault
    }
    
    struct PaymentContract: Equatable {}
    
    typealias ConsentResult = Result<ConsentList, ConsentError>
    
    struct ConsentList: Equatable {}
    struct ConsentError: Error, Equatable {}
    
    enum BankDefault: Equatable {
        
        case onDisabled
        case offEnabled
        case offDisabled
    }
    
    enum ContractStatus: Equatable {
        
        case active, inactive
    }
    
    enum Failure: Equatable {
        
        case serverError(String)
        case connectivityError
    }
}
