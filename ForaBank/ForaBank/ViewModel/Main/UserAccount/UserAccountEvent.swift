//
//  UserAccountEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.01.2024.
//

import FastPaymentsSettings
import ManageSubscriptionsUI
import OTPInputComponent
import SwiftUI
import UIPrimitives

indirect enum UserAccountEvent {
    
    case alertButtonTapped(UserAccountEvent)
    case dismiss(DismissEvent)
    case navigate(NavigateEvent)
    
    case cancelC2BSub(SubscriptionViewModel.Token)
    case deleteRequest
    case exit
    
    case fps(FastPaymentsSettings)
    case otp(OTPEvent)
}

extension UserAccountEvent {
    
    enum DismissEvent {
        
        case alert
        case bottomSheet
        case destination
        case fpsAlert
        case fpsDestination
        case informer
        case route
        case sheet
        case textFieldAlert
    }
    
    enum NavigateEvent {
        
        case alert(AlertModelOf<UserAccountEvent>)
        case bottomSheet(UserAccountRoute.BottomSheet)
        case link(UserAccountRoute.Link)
        case spinner
        case textFieldAlert(AlertTextFieldView.ViewModel)
    }
}

extension UserAccountEvent {
    
    enum FastPaymentsSettings: Equatable {
        
        case dismissFPSDestination
        case updated(FastPaymentsSettingsState)
    }
    
    enum OTPEvent: Equatable {
        
        case create(TimedOTPRoute)
        case otpInput(OTPInputStateProjection)
        case prepareSetBankDefault
        case prepareSetBankDefaultResponse(PrepareSetBankDefaultResponse)
        
        typealias TimedOTPRoute = GenericRoute<TimedOTPInputViewModel, Never, Never, Never>
        
        enum PrepareSetBankDefaultResponse: Equatable {
            
            case success(OTPInputState.PhoneNumberMask)
            case connectivityError
            case serverError(String)
        }
    }
}
