//
//  UserAccountEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.01.2024.
//

import Foundation
import ManageSubscriptionsUI
import OTPInputComponent

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
        
        case dismissInformer(TimeInterval = 2)
        case otp(OTP)
    }
}

extension UserAccountEffect.NavigationEffect {
    
    enum OTP: Equatable {
        
        case create(OTPInputState.PhoneNumberMask)
        case prepareSetBankDefault(OTPInputState.PhoneNumberMask)
    }
}
