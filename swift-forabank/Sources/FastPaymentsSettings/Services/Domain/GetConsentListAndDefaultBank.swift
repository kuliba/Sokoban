//
//  GetConsentListAndDefaultBankResults.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

public struct GetConsentListAndDefaultBank: Equatable {
    
    public let consentList: ConsentList
    public let defaultBank: DefaultBank
    
    public init(
        consentList: ConsentList, 
        defaultBank: DefaultBank
    ) {
        self.consentList = consentList
        self.defaultBank = defaultBank
    }
}
