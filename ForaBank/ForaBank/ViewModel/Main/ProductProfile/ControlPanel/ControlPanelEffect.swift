//
//  ControlPanelEffect.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import SwiftUI
import UIPrimitives

enum ControlPanelEffect {
        
    case delayAlert(Alert.ViewModel, DispatchTimeInterval)
    case delayAlertModelOf(AlertModelOf<ControlPanelEvent>, DispatchTimeInterval)

    case blockCard(ProductCardData)
    case unblockCard(ProductCardData)
    case visibility(ProductCardData)
    case loadSVCardLanding(ProductCardData)
    case loadSVCardLimits(ProductCardData)
}
