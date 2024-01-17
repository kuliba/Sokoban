//
//  anyConsent.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import Foundation

func anyConsent(count: Int = 10) -> ConsentListEffect.Consent {
    
    let array = (0...Int.random(in: 0...count)).map { _ in
        
        Bank.ID(UUID().uuidString)
    }
    
    return .init(array)
}
