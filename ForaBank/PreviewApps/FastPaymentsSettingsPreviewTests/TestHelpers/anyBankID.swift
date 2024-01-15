//
//  anyBankID.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import Foundation

func anyBankID() -> Bank.ID {
    
    .init(UUID().uuidString)
}
