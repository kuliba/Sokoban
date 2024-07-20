//
//  ControlPanelEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import LandingUIComponent
import SVCardLimitAPI

enum ControlPanelEvent {
    
    case controlButtonEvent(ControlButtonEvent)
    case updateState([ControlPanelButtonDetails])
    case updateProducts
    case updateTitle(String)
    case loadSVCardLanding(ProductCardData)
    case loadedSVCardLanding(LandingWrapperViewModel?, ProductCardData)
    case loadedSVCardLimits([GetSVCardLimitsResponse.LimitItem]?)

    case bannerEvent(BannerActionEvent)
    case dismissDestination
    case openSubscriptions(SubscriptionsViewModel)
}

enum BannerActionEvent {
    case stickerEvent(StickerEvent)
    case contactTransfer(PaymentsViewModel)
    case migTransfer(PaymentsViewModel)
    case openDeposit(OpenDepositDetailViewModel)
    case openDepositsList(OpenDepositListViewModel)
}
