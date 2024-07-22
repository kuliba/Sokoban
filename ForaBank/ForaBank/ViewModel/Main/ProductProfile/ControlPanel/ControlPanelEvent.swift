//
//  ControlPanelEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import LandingUIComponent
import SVCardLimitAPI
import ManageSubscriptionsUI
import SwiftUI

enum ControlPanelEvent {
    
    case controlButtonEvent(ControlButtonEvent)
    case updateState([ControlPanelButtonDetails])
    case updateProducts
    case updateTitle(String)
    case loadSVCardLanding(ProductCardData)
    case loadedSVCardLanding(LandingWrapperViewModel?, ProductCardData)
    case loadedSVCardLimits([GetSVCardLimitsResponse.LimitItem]?)

    case bannerEvent(BannerActionEvent)
    case dismiss(DismissEvent)

    case alert(Alert.ViewModel)
    case destination(ControlPanelState.Destination)

    case cancelC2BSub(SubscriptionViewModel.Token)
}

extension ControlPanelEvent {
    
    enum DismissEvent {
        
        case alert
        case destination
    }
}

enum BannerActionEvent {
    case stickerEvent(StickerEvent)
    case contactTransfer(PaymentsViewModel)
    case migTransfer(PaymentsViewModel)
    case openDeposit(OpenDepositDetailViewModel)
    case openDepositsList(OpenDepositListViewModel)
}
