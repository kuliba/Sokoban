//
//  GetConsentListAndDefaultBank.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

struct GetConsentListAndDefaultBank {
    
    typealias ConsentListResult = Result<[BankID], GetConsentListError>
    typealias DefaultBankResult = Result<DefaultBank, GetDefaultBankError>
    
    let consentListResult: ConsentListResult
    let defaultBankResult: DefaultBankResult
}

#warning("move error types to separate files?")

enum GetConsentListError: Error, Equatable {
    
    case connectivity
    case server(statusCode: Int, errorMessage: String)
}

enum GetDefaultBankError: Error, Equatable {
    
    case connectivity
    case limit(message: String)
    case server(statusCode: Int, errorMessage: String)
}
