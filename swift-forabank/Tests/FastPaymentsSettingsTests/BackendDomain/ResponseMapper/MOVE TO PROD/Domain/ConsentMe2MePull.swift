//
//  ConsentMe2MePull.swift
//  
//
//  Created by Igor Malyarov on 28.12.2023.
//

struct ConsentMe2MePull: Equatable {
    
    let consentID: Int
    let bankID: String
    #warning("replace with Date")
    let beginDate: String
    #warning("replace with Date")
    let endDate: String
    #warning("replace with non optional")
    let active: Bool?
    #warning("replace with non optional")
    let oneTimeConsent: Bool?
}
