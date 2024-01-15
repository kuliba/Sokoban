//
//  anyBankID.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

@testable import FastPaymentsSettingsPreview
import Foundation

func anyBankID() -> Bank.ID {
    
    .init(UUID().uuidString)
}
