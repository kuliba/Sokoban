//
//  FastPaymentsSettingsEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

enum FastPaymentsSettingsEvent {
    
    case appear
    case activateContract
    case deactivateContract
#warning("rename case to reflect meaning")
    case resetError
    case setBankDefault
    case prepareSetBankDefault
    case confirmSetBankDefault
}
