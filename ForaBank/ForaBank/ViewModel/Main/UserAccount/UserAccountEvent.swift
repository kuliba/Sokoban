//
//  UserAccountEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.01.2024.
//

import SwiftUI
import ManageSubscriptionsUI
import UserAccountNavigationComponent
import UIPrimitives

enum UserAccountEvent {
    
    #warning("suboptimal event structure, needs cleaning")
    case closeAlert
    case closeFPSAlert
    case dismissDestination
    case dismissFPSDestination
    case dismissRoute
    
    case alertButtonTapped(AlertButtonTap)
    case route(RouteEvent)
    case fps(FastPaymentsSettings)
    case otp(OTP)
}

extension UserAccountEvent {
    
    enum AlertButtonTap {
        
        #warning("suboptimal event structure, needs cleaning")
        case closeAlert
        case closeFPSAlert
        case dismissDestination
        case dismissFPSDestination
        case dismissRoute

        case fps(FastPaymentsSettings)
        case otp(OTP)
        
        case cancelC2BSub(SubscriptionViewModel.Token)
        case delete
        case exit
    }
    
    enum RouteEvent {
        
        case alert(AlertEvent)
        case bottomSheet(BottomSheetEvent)
        case link(LinkEvent)
        case spinner(SpinnerEvent)
        case sheet(SheetEvent)
        case textFieldAlert(TextFieldAlertEvent)
        
        enum AlertEvent {
            
            case reset
            case setTo(AlertModelOf<AlertButtonTap>)
        }
        
        enum BottomSheetEvent {
            
            case reset
            case setTo(UserAccountRoute.BottomSheet)
        }
        
        enum LinkEvent {
            
            case reset
            case setTo(UserAccountRoute.Link)
        }
        
        enum SpinnerEvent {
            
            case hide, show
        }
        
        enum SheetEvent {
            
            case reset
        }
        
        enum TextFieldAlertEvent {
            
            case reset
            case setTo(AlertTextFieldView.ViewModel)
        }
    }
}

extension UserAccountEvent {
    
    typealias FastPaymentsSettings = UserAccountNavigation.Event.FastPaymentsSettings
    typealias OTP = UserAccountNavigation.Event.OTP
}
