//
//  ConsentListEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

enum ConsentListEvent: Equatable {
    
    case toggle
    case search(String)
    case tapBank(Bank.ID)
    case apply
    case consent(Consent)
    case consentFailure(ConsentFailure)
}

extension ConsentListEvent {
    
    enum ConsentFailure: Equatable {
        
        case connectivityError
        case serverError(String)
    }
}
