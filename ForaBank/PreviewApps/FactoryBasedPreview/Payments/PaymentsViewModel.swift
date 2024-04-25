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
    
    private let prepaymentFlowManager: PrepaymentFlowManager
    private let spinner: (SpinnerEvent) -> Void
    
    init(
        initialState: State,
        prepaymentFlowManager: PrepaymentFlowManager,
        spinner: @escaping (SpinnerEvent) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.prepaymentFlowManager = prepaymentFlowManager
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

        case let .prepaymentFlow(paymentFlowEvent):
            let (paymentFlowState, paymentFlowEffect) = prepaymentFlowManager.reduce(state.paymentFlowState, paymentFlowEvent)
            state.destination = paymentFlowState.destination.map(State.Destination.prepaymentFlow)
            effect = paymentFlowEffect.map(Effect.prepaymentFlow)
        }
        
        return (state, effect)
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .prepaymentFlow(effect):
            prepaymentFlowManager.handleEffect(effect) { dispatch(.prepaymentFlow($0)) }
        }
    }
}

private extension PaymentsState {
    
    var paymentFlowState: PrepaymentFlowState {
        
        guard case let .prepaymentFlow(destination) = destination
        else { return .init() }
        
        return .init(destination: destination)
    }
}

private extension PaymentsViewModel {
    
    func reduce(
        _ state: State,
        _ event: Event.ButtonTapped
    ) -> (State, Effect?) {
        
        var effect: Effect?
        
        switch event {
        case .mobile:
            print("`mobile` event occurred")
            
        case .utilityService:
            effect = .prepaymentFlow(.initiateUtilityPayment)
        }
        
        return (state, effect)
    }
}
