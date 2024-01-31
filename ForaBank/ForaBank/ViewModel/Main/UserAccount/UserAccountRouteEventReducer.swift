//
//  UserAccountRouteEventReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.01.2024.
//

final class UserAccountRouteEventReducer {
    
}

extension UserAccountRouteEventReducer {
    
    func reduce(
        _ route: UserAccountRoute,
        _ routeEvent: UserAccountEvent.RouteEvent,
        _ dispatch: @escaping Dispatch
    ) -> UserAccountRoute {
        
        var route = route
        
        switch routeEvent {
        case let .alert(alertEvent):
            switch alertEvent {
            case .reset:
                route.alert = nil
                
            case let .setTo(alertViewModel):
                route.alert = alertViewModel
            }
            
        case let .bottomSheet(bottomSheetEvent):
            switch bottomSheetEvent {
            case .reset:
                route.bottomSheet = nil
                
            case let .setTo(bottomSheet):
                route.bottomSheet = bottomSheet
            }
            
        case let .link(linkEvent):
            switch linkEvent {
            case .reset:
                route.link = nil
                
            case let .setTo(link):
                route.link = link
            }
            
        case let .sheet(sheetEvent):
            switch sheetEvent {
            case .reset:
                route.sheet = nil
            }
            
        case let .spinner(spinnerEvent):
            switch spinnerEvent {
            case .hide:
                route.spinner = nil
                
            case .show:
                route.spinner = .init()
            }
            
        case let .textFieldAlert(textFieldAlertEvent):
            switch textFieldAlertEvent {
            case .reset:
                route.textFieldAlert = nil
                
            case let .setTo(alertViewModel):
                route.textFieldAlert = alertViewModel
            }
        }
        
        return route
    }
}

extension UserAccountRouteEventReducer {
    
    typealias Dispatch = (UserAccountEvent.RouteEvent) -> Void
}
