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
    
    private let paymentManager: PaymentManager
    private let rootEvent: (RootEvent) -> Void
    
    init(
        initialState: State,
        paymentManager: PaymentManager,
        rootEvent: @escaping (RootEvent) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.paymentManager = paymentManager
        self.rootEvent = rootEvent
        
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
        
        rootEvent(.spinner((effect == nil ? .hide: .show)))
        
        if let effect {
            
            handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

extension PaymentsViewModel {
    
    typealias Dispatch = (Event) -> Void
    
    #warning("actually more complex state here, PaymentsState is just a part of it (substate) | extract reduce & effectHandler but mind the substate case here! - see commented extension below")
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
        case let .paymentButtonTapped(button):
            (state, effect) = reduce(state, button)
            
        case .dismissDestination:
            state.destination = nil

        case let .payment(paymentEvent):
            (state, effect) = reduce(state, paymentEvent)
        }
        
        return (state, effect)
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .payment(paymentEffect):
            paymentManager.handleEffect(paymentEffect) { dispatch(.payment($0)) }
        }
    }
}

//private extension PaymentsState {
//    
//    var paymentFlowState: PaymentDestinationState {
//        
//        guard case let .prepaymentFlow(destination) = destination
//        else { return .init() }
//        
//        return .init(destination: destination)
//    }
//}

private extension PaymentsViewModel {
    
    func reduce(
        _ state: State,
        _ button: Event.PaymentButton
    ) -> (State, Effect?) {
        
        var effect: Effect?
        
        switch button {
        case .mobile:
            print("`mobile` event occurred")
            
        case .utilityService:
            effect = .payment(.utilityService(.initiate))
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: PaymentEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
    }
}
