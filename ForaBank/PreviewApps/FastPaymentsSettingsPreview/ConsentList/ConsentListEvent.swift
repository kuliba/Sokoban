//
//  ConsentListEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

enum ConsentListEvent {
    
    case toggle
    case search(String)
    case tapBank(Bank.ID)
    case apply
}
