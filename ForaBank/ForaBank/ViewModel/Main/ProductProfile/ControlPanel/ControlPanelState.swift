//
//  ControlPanelState.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import UIPrimitives
import SwiftUI
import LandingUIComponent

struct ControlPanelState {
    
    var buttons: [ControlPanelButtonDetails]
    var status: Status?
    var alert: Alert.ViewModel?
    var spinner: SpinnerView.ViewModel?
    var navigationBarViewModel: NavigationBarView.ViewModel
    var landingWrapperViewModel: LandingWrapperViewModel?
    var destination: Destination?

    init(
        buttons: [ControlPanelButtonDetails],
        status: Status? = nil,
        alert: Alert.ViewModel? = nil,
        spinner: SpinnerView.ViewModel? = nil,
        navigationBarViewModel: NavigationBarView.ViewModel,
        landingWrapperViewModel: LandingWrapperViewModel? = nil,
        destination: Destination? = nil
    ) {
        self.buttons = buttons
        self.status = status
        self.alert = alert
        self.spinner = spinner
        self.navigationBarViewModel = navigationBarViewModel
        self.landingWrapperViewModel = landingWrapperViewModel
        self.destination = destination
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
    
    enum Destination: Identifiable {
        
        case contactTransfer(PaymentsViewModel)
        case migTransfer(PaymentsViewModel)
        case landing(AuthProductsViewModel)
        case orderSticker(any View)
        case openDeposit(OpenDepositDetailViewModel)
        case openDepositsList(OpenDepositListViewModel)

        var id: _Case { _case }
        
        var _case: _Case {
            
            switch self {
            case .contactTransfer: return .contactTransfer
            case .migTransfer: return .migTransfer
            case .landing: return .landing
            case .orderSticker: return .orderSticker
            case .openDeposit: return .openDeposit
            case .openDepositsList: return .openDepositsList
            }
        }
        
        enum _Case {
            
            case contactTransfer, migTransfer
            case landing, orderSticker
            case openDeposit, openDepositsList
        }
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
