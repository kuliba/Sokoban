//
//  PaymentsReducer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

final class PaymentsReducer {}

extension PaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismissDestination:
            state.destination = nil
            
        case let .payment(paymentEvent):
            (state, effect) = reduce(state, paymentEvent)
        }
        
        return (state, effect)
    }
}

extension PaymentsReducer {
    
    typealias State = PaymentsState
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
}

private extension PaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: PaymentEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .buttonTapped(button):
            (state, effect) = reduce(state, button)
            
        case let .initiated(initiated):
            (state, effect) = reduce(state, initiated)
            
        case let .utilityService(utilityServiceEvent):
            (state, effect) = reduce(state, utilityServiceEvent)
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: PaymentEvent.PaymentButton
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .mobile:
            print("`mobile` event occurred")
            
        case .utilityService:
            effect = .initiate(.utilityPayment)
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: PaymentEvent.Initiated
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .utilityPayment(response):
            state.destination = .utilityService(.prepayment(.init(
                lastPayments: response.lastPayments,
                operators: response.operators
            )))
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: UtilityServicePaymentEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .prepayment(prepaymentEvent):
            (state, effect) = reduce(state, prepaymentEvent)
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: UtilityServicePrepaymentEvent
    ) -> (State, Effect?) {
        
        fatalError("delegate to UtilityPrepaymentPickerEventReduce?")
    }
}
