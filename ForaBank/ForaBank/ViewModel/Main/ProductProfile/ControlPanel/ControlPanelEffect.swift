//
//  ControlPanelEffect.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import SwiftUI
import ManageSubscriptionsUI

enum ControlPanelEffect {
    
    case delayAlert(Alert.ViewModel, DispatchTimeInterval)

    case blockCard(ProductCardData)
    case unblockCard(ProductCardData)
    case visibility(ProductCardData)
    case loadSVCardLanding(ProductCardData)
    case loadSVCardLimits(ProductCardData)
    
    case model(ModelEffect)
}

extension ControlPanelEffect {
    
    enum ModelEffect: Equatable {
        
        case cancelC2BSub(SubscriptionViewModel.Token)
    }
}
