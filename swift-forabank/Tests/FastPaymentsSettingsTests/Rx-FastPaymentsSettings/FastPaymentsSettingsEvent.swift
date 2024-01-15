//
//  FastPaymentsSettingsEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

public enum FastPaymentsSettingsEvent: Equatable {
    
    case appear
    case activateContract
    case deactivateContract
#warning("rename case to reflect meaning")
    case resetStatus
    case setBankDefault
    case prepareSetBankDefault
    case confirmSetBankDefault
}
