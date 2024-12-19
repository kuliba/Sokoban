//
//  ConsentListEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

public enum ConsentListEvent: Equatable {
    
    case toggle
    case search(String)
    case tapBank(Bank.ID)
    case applyConsent
    case changeConsent(Consent)
    case changeConsentFailure(ServiceFailure)
    case resetStatus
}
