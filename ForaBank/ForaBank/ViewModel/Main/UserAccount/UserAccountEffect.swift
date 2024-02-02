//
//  UserAccountEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.01.2024.
//

import ManageSubscriptionsUI
import UserAccountNavigationComponent

enum UserAccountEffect {
    
    case model(ModelEffect)
    case navigation(UserAccountNavigation.Effect)
}

extension UserAccountEffect {
    
    enum ModelEffect {
        
        case cancelC2BSub(SubscriptionViewModel.Token)
        case deleteRequest
        case exit
    }
}
