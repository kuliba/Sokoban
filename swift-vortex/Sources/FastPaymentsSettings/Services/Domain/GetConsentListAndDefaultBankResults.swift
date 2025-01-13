//
//  GetConsentListAndDefaultBankResults.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

public struct GetConsentListAndDefaultBankResults {
    
    public typealias ConsentListResult = Result<Consents, GetConsentListError>
    public typealias DefaultBankResult = Result<DefaultBank, GetDefaultBankError>
    
    public let consentListResult: ConsentListResult
    public let defaultBankResult: DefaultBankResult
    
    public init(
        consentListResult: ConsentListResult,
        defaultBankResult: DefaultBankResult
    ) {
        self.consentListResult = consentListResult
        self.defaultBankResult = defaultBankResult
    }
}

public extension GetConsentListAndDefaultBankResults {
    
    enum GetConsentListError: Error, Equatable {
        
        case connectivity
        case server(statusCode: Int, errorMessage: String)
    }
    
    enum GetDefaultBankError: Error, Equatable {
        
        case connectivity
        case limit(message: String)
        case server(statusCode: Int, errorMessage: String)
    }
}
