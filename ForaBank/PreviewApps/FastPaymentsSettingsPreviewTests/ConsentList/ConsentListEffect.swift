//
//  ConsentListEffect.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

@testable import FastPaymentsSettingsPreview

enum ConsentListEffect: Equatable {

    case apply(Consent)
}

extension ConsentListEffect {
    
    typealias Consent = Set<Bank.ID>
}
