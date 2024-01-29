//
//  UserAccountNavigation+Event.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent

public extension UserAccountNavigation {
    
    enum Event: Equatable {
        
        case closeAlert
        case closeFPSAlert
        case dismissFPSDestination
        case dismissDestination
        case dismissRoute
        
        case demo(Demo)
        case fps(FastPaymentsSettings)
        case otp(OTP)
    }
}

public extension UserAccountNavigation.Event {
    
    enum Demo: Equatable {
        
        case loaded(Show)
        case show(Show)
        
        public enum Show: Equatable {
            case alert
            case informer
            case loader
        }
    }
    
    enum FastPaymentsSettings: Equatable {
        
        case updated(FastPaymentsSettingsState)
    }
    
    enum OTP: Equatable {
        
        case otpInput(OTPInputStateProjection)
        case prepareSetBankDefault
        case prepareSetBankDefaultResponse(PrepareSetBankDefaultResponse)
        
        public enum PrepareSetBankDefaultResponse: Equatable {
            
            case success
            case connectivityError
            case serverError(String)
        }
    }
}

// MARK: - OTP for Fast Payments Settings

public enum OTPInputStateProjection: Equatable {
    
    case failure(OTPInputComponent.ServiceFailure)
    case inflight
    case validOTP
}
