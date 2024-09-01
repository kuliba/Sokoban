//
//  PaymentProviderPickerFlowReducer.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public final class PaymentProviderPickerFlowReducer<Latest, Payment, PayByInstructions, Provider, Service> {
    
    public init() {}
}

public extension PaymentProviderPickerFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .initiatePaymentResult(result):
            self.initiatePaymentResult(&state, &effect, with: result)
            
        case let .loadServices(services):
            self.loadServices(&state, &effect, with: services)
            
        case let .payByInstructions(payByInstructions):
            state.navigation = .destination(.payByInstructions(payByInstructions))
            
        case let .select(select):
            self.select(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

public extension PaymentProviderPickerFlowReducer {
    
    typealias State = PaymentProviderPickerFlowState<PayByInstructions, Payment, Service>
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
    
    func loadServices(
        _ state: inout State,
        _ effect: inout Effect?,
        with services: Event.Services?
    ) {
        switch services {
        case .none:
            state.navigation = .destination(.servicesFailure)
            
        case let .some(services):
            state.navigation = .destination(.services(services))
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
