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
        #warning("supershort - could be handled inside parent reducer")
        var state = state
        
        switch event {
        case let .alert(alertViewModel):
            state.alert = alertViewModel
            
        case let .bottomSheet(bottomSheet):
            state.bottomSheet = bottomSheet
            
        case let .link(link):
            state.link = link
            
        case .spinner:
            state.spinner = .init()
            
        case let .textFieldAlert(textFieldAlert):
            state.textFieldAlert = textFieldAlert
        }
        
        return state
    }
    
}

extension UserAccountRouteEventReducer {
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent.NavigateEvent
}
