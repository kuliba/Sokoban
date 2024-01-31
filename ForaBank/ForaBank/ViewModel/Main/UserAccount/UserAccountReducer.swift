//
//  UserAccountReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.01.2024.
//

import UserAccountNavigationComponent

final class UserAccountReducer {
    
    //    private let navigationReduce: NavigationReduce
    //
    //    init(navigationReduce: @escaping NavigationReduce) {
    //
    //        self.navigationReduce = navigationReduce
    //    }
    //}
    //
    //extension UserAccountRouteEventReducer {
    //
    //    convenience init(userAccountNavigationReducer: UserAccountNavigationReducer) {
    //
    //        self.init(
    //            navigationReduce: { state, event, dispatch in
    //
    //                userAccountNavigationReducer.reduce(
    //                    state,
    //                    event,
    //                    // informer is part of the state
    //                    { _ in },
    //                    dispatch
    //                )
    //            }
    //        )
    //    }
}

extension UserAccountReducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ dispatch: @escaping RouteDispatch
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .route(routeEvent):
            state = reduce(state, routeEvent, dispatch)
            
        case let .fps(fastPaymentsSettings):
            (state, effect) = reduce(state, with: fastPaymentsSettings)
            
        case let .otp(otpEvent):
            (state, effect) = reduce(state, with: otpEvent)
        }
        
        return (state, effect)
    }
}

extension UserAccountReducer {
    
    typealias RouteDispatch = (Event.RouteEvent) -> Void
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent
    typealias Effect = UserAccountEffect
    
    typealias NavigationReduce = (NavigationState, NavigationEvent, @escaping RouteDispatch) -> (NavigationState, NavigationEffect?)
    
    typealias NavigationState = UserAccountNavigation.State
    typealias NavigationEvent = UserAccountNavigation.Event
    typealias NavigationEffect = UserAccountNavigation.Effect
}

private extension UserAccountReducer {
    
    func reduce(
        _ route: UserAccountRoute,
        _ routeEvent: UserAccountEvent.RouteEvent,
        _ dispatch: @escaping RouteDispatch
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

private extension UserAccountReducer {
    
    func reduce(
        _ state: State,
        with fpsEvent: Event.FastPaymentsSettings
    ) -> (State, Effect?) {
        
        fatalError()
    }
}

private extension UserAccountReducer {
    
    func reduce(
        _ state: State,
        with otpEvent: Event.OTP
    ) -> (State, Effect?) {
        
        fatalError()
    }
}
