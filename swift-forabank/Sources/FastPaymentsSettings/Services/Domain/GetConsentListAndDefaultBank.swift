//
//  GetConsentListAndDefaultBankResults.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

public struct GetConsentListAndDefaultBank: Equatable {
    
    public let consentList: Consents
    public let defaultBank: DefaultBank
    
    public init(
        consentList: Consents, 
        defaultBank: DefaultBank
    ) {
        self.consentList = consentList
        self.defaultBank = defaultBank
    }
}
