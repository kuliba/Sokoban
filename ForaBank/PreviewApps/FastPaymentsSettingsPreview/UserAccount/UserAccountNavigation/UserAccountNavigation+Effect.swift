//
//  UserAccountNavigation+Effect.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import FastPaymentsSettings

extension UserAccountNavigation {
    
    enum Effect: Equatable {
        
        case demo(Demo)
        case fps(FastPaymentsSettingsEvent)
        case otp(OTP)
        
        enum Demo: Equatable {
            
            case loadAlert
            case loadInformer
            case loader
        }
        
        enum OTP: Equatable {
            
            case prepareSetBankDefault
        }
    }
}
