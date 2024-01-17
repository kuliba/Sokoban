//
//  ConsentListEffect.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public enum ConsentListEffect: Equatable {

    case apply(Consent)
}

public extension ConsentListEffect {
    
    typealias Consent = Set<Bank.ID>
}
