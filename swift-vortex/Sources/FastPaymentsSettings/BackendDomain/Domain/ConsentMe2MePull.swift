//
//  ConsentMe2MePull.swift
//  
//
//  Created by Igor Malyarov on 28.12.2023.
//

public struct ConsentMe2MePull: Equatable {
    
    public let consentID: Int
    public let bankID: String
    #warning("replace with Date")
    public let beginDate: String
    #warning("replace with Date")
    public let endDate: String
    #warning("replace with non optional")
    public let active: Bool?
    #warning("replace with non optional")
    public let oneTimeConsent: Bool?
    
    public init(
        consentID: Int, 
        bankID: String,
        beginDate: String,
        endDate: String,
        active: Bool?,
        oneTimeConsent: Bool?
    ) {
        self.consentID = consentID
        self.bankID = bankID
        self.beginDate = beginDate
        self.endDate = endDate
        self.active = active
        self.oneTimeConsent = oneTimeConsent
    }
}
