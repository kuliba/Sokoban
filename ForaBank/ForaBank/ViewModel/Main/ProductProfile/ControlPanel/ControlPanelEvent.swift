//
//  ControlPanelEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import LandingUIComponent

enum ControlPanelEvent {
    
    case controlButtonEvent(ControlButtonEvent)
    case updateState([ControlPanelButtonDetails])
    case updateProducts
    case updateTitle(String)
    case loadSVCardLanding(ProductCardData)
    case loadedSVCardLanding(LandingWrapperViewModel?)
}
