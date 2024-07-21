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
import UIPrimitives

indirect enum ControlPanelEvent {
    
    case controlButtonEvent(ControlButtonEvent)
    case updateState([ControlPanelButtonDetails])
    case updateProducts
    case updateTitle(String)
    case loadSVCardLanding(ProductCardData)
    case loadedSVCardLanding(LandingWrapperViewModel?, ProductCardData)
    case loadedSVCardLimits([GetSVCardLimitsResponse.LimitItem]?)

    case bannerEvent(BannerActionEvent)
    case dismiss(DismissEvent)

    case alert(AlertModelOf<ControlPanelEvent>)

    case openSubscriptions(SubscriptionsViewModel)
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
