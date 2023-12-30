//
//  GetConsentListAndDefaultBank.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

struct GetConsentListAndDefaultBank {
    
    let consentListResult: Result<[BankID], Error>
    let defaultBankResult: Result<DefaultBank, Error>
}
