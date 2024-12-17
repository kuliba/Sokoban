//
//  UserAccountReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.02.2024.
//

import FastPaymentsSettings
import OTPInputComponent
import UserAccountNavigationComponent

final class UserAccountReducer {
    
    private let fpsReduce: FPSReduce
    private let otpReduce: OTPReduce
    
    init(
        fpsReduce: @escaping FPSReduce,
        otpReduce: @escaping OTPReduce
    ) {
        self.fpsReduce = fpsReduce
        self.otpReduce = otpReduce
    }
}

extension UserAccountReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .alertButtonTapped(alertButtonTapped):
            (state, effect) = reduce(state, alertButtonTapped)
            
        case let .dismiss(dismiss):
            state = reduce(state, dismiss)
            
        case let .navigate(navigateEvent):
            state = reduce(state, navigateEvent)
            
        case let .cancelC2BSub(token):
            effect = .model(.cancelC2BSub(token))
            
        case .deleteRequest:
            effect = .model(.deleteRequest)
            
        case .exit:
            effect = .model(.exit)
        
        case let .fps(fastPaymentsSettings):
            (state, effect) = fpsReduce(state, fastPaymentsSettings)
            
        case let .otp(otpEvent):
            (state, effect) = otpReduce(state, otpEvent)
        }
        
        return (state, effect)
    }
}

extension UserAccountReducer {
    
    typealias FPSReduce = (State, Event.FastPaymentsSettings) -> (State, Effect?)
    typealias OTPReduce = (State, Event.OTPEvent) -> (State, Effect?)
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent
    typealias Effect = UserAccountEffect
}

private extension UserAccountReducer.State {
    
    var fpsViewModel: FastPaymentsSettingsViewModel? { fpsRoute?.viewModel }
}

private extension UserAccountReducer {
    
#warning("it looks like all `close` and `dismiss` events should be processed with events (effects??) to destinations; and the real dismiss should be encapsulated into state change in reaction to destination state change")
    func reduce(
        _ state: State,
        _ event: Event.DismissEvent
    ) -> State {
        
        var state = state
        
        switch event {
        case .alert:
            state.alert = nil
            state.fpsViewModel?.event(.resetStatus)
            
        case .bottomSheet:
            state.bottomSheet = nil
            
        case .destination:
            state.link = nil
            state.fpsViewModel?.event(.resetStatus)
            
        case .fpsAlert:
            state.alert = nil
            state.fpsViewModel?.event(.resetStatus)
            
        case .fpsDestination:
            // state.fpsDestination = nil
            if var fpsRoute = state.fpsRoute {
                fpsRoute.destination = nil
                state.link = .fastPaymentSettings(.new(fpsRoute))
            }
            state.fpsViewModel?.event(.resetStatus)
            
        case .informer:
            state.informer = nil
            state.fpsViewModel?.event(.resetStatus)
            
        case .route:
            state = .init()
            
        case .sheet:
            state.sheet = nil
            
        case .textFieldAlert:
            state.textFieldAlert = nil
        }
        
        return state
    }
    
    func reduce(
        _ state: State,
        _ event: Event.NavigateEvent
    ) -> State {
        
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
