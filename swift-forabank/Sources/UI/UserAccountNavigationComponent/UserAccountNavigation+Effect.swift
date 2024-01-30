//
//  UserAccountNavigation+Effect.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import FastPaymentsSettings

public extension UserAccountNavigation {
    
    enum Effect: Equatable {
        
        case fps(FastPaymentsSettingsEvent)
        case otp(OTP)
    }
}

public extension UserAccountNavigation.Effect {
    
    enum OTP: Equatable {
        
        case prepareSetBankDefault
    }
}
