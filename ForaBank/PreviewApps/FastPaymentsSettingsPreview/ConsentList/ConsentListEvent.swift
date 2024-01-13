//
//  ConsentListEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

enum ConsentListEvent {
    
    case collapse, expand
    case tapBank(BankID)
    case apply
}
