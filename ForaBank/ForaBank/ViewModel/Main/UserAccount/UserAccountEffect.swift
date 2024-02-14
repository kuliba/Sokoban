//
//  UserAccountEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.01.2024.
//

import ManageSubscriptionsUI
import OTPInputComponent
import UserAccountNavigationComponent

enum UserAccountEffect {
    
    case model(ModelEffect)
    case navigation(NavigationEffect)
}

extension UserAccountEffect {
    
    enum ModelEffect {
        
        case cancelC2BSub(SubscriptionViewModel.Token)
        case deleteRequest
        case exit
    }
}

extension UserAccountEffect {
    
    enum NavigationEffect: Equatable {
        
        case dismissInformer
//        case fps(FastPaymentsSettingsEvent)
        case otp(OTP)
    }
}

extension UserAccountEffect.NavigationEffect {
    
    enum OTP: Equatable {
        
        case create(OTPInputState.PhoneNumberMask)
        case prepareSetBankDefault(OTPInputState.PhoneNumberMask)
    }
}
