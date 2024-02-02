//
//  UserAccountRouteEventReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.01.2024.
//

final class UserAccountRouteEventReducer {}

extension UserAccountRouteEventReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> UserAccountRoute {
        
        var state = state
        
        switch event {
        case let .alert(alertEvent):
            switch alertEvent {
            case .reset:
                state.alert = nil
                
            case let .setTo(alertViewModel):
                state.alert = alertViewModel
            }
            
        case let .bottomSheet(bottomSheetEvent):
            switch bottomSheetEvent {
            case .reset:
                state.bottomSheet = nil
                
            case let .setTo(bottomSheet):
                state.bottomSheet = bottomSheet
            }
            
        case let .link(linkEvent):
            switch linkEvent {
            case .reset:
                state.link = nil
                
            case let .setTo(link):
                state.link = link
            }
            
        case let .sheet(sheetEvent):
            switch sheetEvent {
            case .reset:
                state.sheet = nil
            }
            
        case let .spinner(spinnerEvent):
            switch spinnerEvent {
            case .hide:
                state.spinner = nil
                
            case .show:
                state.spinner = .init()
            }
            
        case let .textFieldAlert(textFieldAlertEvent):
            switch textFieldAlertEvent {
            case .reset:
                state.textFieldAlert = nil
                
            case let .setTo(alertViewModel):
                state.textFieldAlert = alertViewModel
            }
        }
        
        return state
    }
    
}

extension UserAccountRouteEventReducer {
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent.RouteEvent
}
