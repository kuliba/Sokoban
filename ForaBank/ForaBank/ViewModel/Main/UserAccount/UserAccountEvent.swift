//
//  UserAccountEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.01.2024.
//

import SwiftUI

enum UserAccountEvent {
    
    case route(RouteEvent)
}

extension UserAccountEvent {
    
    enum RouteEvent {
        
        case alert(AlertEvent)
        case bottomSheet(BottomSheetEvent)
        case link(LinkEvent)
        case spinner(SpinnerEvent)
        case sheet(SheetEvent)
        case textFieldAlert(TextFieldAlertEvent)
        
        enum AlertEvent {
            
            case reset
            case setTo(Alert.ViewModel)
        }
        
        enum BottomSheetEvent {
            
            case reset
            case setTo(UserAccountViewModel.BottomSheet)
        }
        
        enum LinkEvent {
            
            case reset
            case setTo(UserAccountViewModel.Link)
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
