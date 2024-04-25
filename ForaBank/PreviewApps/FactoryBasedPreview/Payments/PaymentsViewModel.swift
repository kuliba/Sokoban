//
//  PaymentsViewModel.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class PaymentsViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let stateSubject = PassthroughSubject<State, Never>()
    
    private let paymentFlowManager: PaymentFlowManager
    private let spinner: (SpinnerEvent) -> Void
    
    init(
        initialState: State,
        paymentFlowManager: PaymentFlowManager,
        spinner: @escaping (SpinnerEvent) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.paymentFlowManager = paymentFlowManager
        self.spinner = spinner
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension PaymentsViewModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        spinner(effect == nil ? .hide: .show)
        
        if let effect {
            
            handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

extension PaymentsViewModel {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = PaymentsState
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
}

private extension PaymentsViewModel {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .buttonTapped(buttonTapped):
            (state, effect) = reduce(state, buttonTapped)
            
        case .dismissDestination:
            state.destination = nil

        case let .paymentFlow(paymentFlowEvent):
            let (paymentFlowState, paymentFlowEffect) = paymentFlowManager.reduce(state.paymentFlowState, paymentFlowEvent)
            state.destination = paymentFlowState.destination.map(State.Destination.paymentFlow)
            effect = paymentFlowEffect.map(Effect.paymentFlow)
        }
        
        return (state, effect)
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .paymentFlow(effect):
            paymentFlowManager.handleEffect(effect) { dispatch(.paymentFlow($0)) }
        }
    }
}

private extension PaymentsState {
    
    var paymentFlowState: PaymentFlowState {
        
        guard case let .paymentFlow(destination) = destination
        else { return .init() }
        
        return .init(destination: destination)
    }
}

private extension PaymentsViewModel {
    
    func reduce(
        _ state: State,
        _ event: Event.ButtonTapped
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .mobile:
            print("`mobile` event occurred")
            
        case .utilityService:
            effect = .paymentFlow(.initiateUtilityPayment)
        }
        
        return (state, effect)
    }

}
