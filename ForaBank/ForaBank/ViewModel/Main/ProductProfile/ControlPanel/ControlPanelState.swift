//
//  ControlPanelState.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import UIPrimitives
import SwiftUI

struct ControlPanelState {
    
    var buttons: [ControlPanelButtonDetails]
    var status: Status?
    var alert: AlertModelOf<Event>?

    init(
        buttons: [ControlPanelButtonDetails],
        status: Status? = nil,
        alert: AlertModelOf<Event>? = nil
    ) {
        self.buttons = buttons
        self.status = status
        self.alert = alert
    }
}

extension ControlPanelState {

    enum Status: Equatable {
        
        case inflight(RequestType)
    }
    
    enum RequestType {
        case block, unblock
        case visibility
        case updateProducts
    }
}

extension ControlPanelState {
    
    typealias Event = ControlPanelNavigationEvent
}

enum ControlPanelNavigationEvent {
    
    case closeAlert
    case dismissDestination
    case showAlert(AlertModelOf<AlertEvent>)
    case showAlertViewModel(Alert.ViewModel)
}
