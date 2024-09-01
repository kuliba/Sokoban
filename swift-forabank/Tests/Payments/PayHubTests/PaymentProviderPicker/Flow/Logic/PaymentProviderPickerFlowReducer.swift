//
//  PaymentProviderPickerFlowReducer.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

final class PaymentProviderPickerFlowReducer<Latest, Payment, PayByInstructions, Provider, Service> {
    
    init() {}
}

extension PaymentProviderPickerFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .initiatePaymentResult(result):
            self.initiatePaymentResult(&state, &effect, with: result)
            
        case let .loadServices(services):
#warning("FIXME")
            
        case let .payByInstructions(payByInstructions):
#warning("FIXME")
            
        case let .select(select):
            self.select(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

extension PaymentProviderPickerFlowReducer {
    
    typealias State = PaymentProviderPickerFlowState<Payment>
    typealias Event = PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider, Service>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
}

private extension PaymentProviderPickerFlowReducer {
    
    func initiatePaymentResult(
        _ state: inout State,
        _ effect: inout Effect?,
        with result: Event.InitiatePaymentResult
    ) {
        switch result {
        case let .failure(serviceFailure):
            state.navigation = .alert(serviceFailure)
            
        case let .success(payment):
            state.navigation = .destination(.payment(payment))
        }
    }
    
    func select(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select
    ) {
        switch select {
        case .back:
            state.navigation = .outside(.back)
            
        case .chat:
            state.navigation = .outside(.chat)
            
        case let .latest(latest):
            state.isLoading = true
            effect = .select(.latest(latest))
            
        case .payByInstructions:
            effect = .select(.payByInstructions)
            
        case let .provider(provider):
            state.isLoading = true
            effect = .select(.provider(provider))
            
        case .qr:
            state.navigation = .outside(.qr)
        }
    }
}
