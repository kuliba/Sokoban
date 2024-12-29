//
//  PaymentProviderPickerFlowReducer.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public final class PaymentProviderPickerFlowReducer<Destination, Latest, Provider> {
    
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
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .receive(navigation):
            switch navigation {
            case let .alert(serviceFailure):
                state.navigation = .alert(serviceFailure)
                
            case let .destination(destination):
                state.navigation = .destination(destination)
                
            case let .outside(outside):
                state.navigation = .outside(outside)
            }
                        
        case let .select(select):
            self.select(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

public extension PaymentProviderPickerFlowReducer {
    
    typealias State = PaymentProviderPickerFlowState<Destination>
    typealias Event = PaymentProviderPickerFlowEvent<Destination, Latest, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
}

private extension PaymentProviderPickerFlowReducer {
    
    typealias Select = PaymentProviderPickerFlowSelect<Latest, Provider>
    
    func select(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Select
    ) {
        switch select {
        case .detailPayment:
            effect = .select(.detailPayment)
            
        case let .latest(latest):
            state.isLoading = true
            effect = .select(.latest(latest))
            
        case let .outside(outside):
            switch outside {
            case .back:
                state.navigation = .outside(.back)
                
            case .chat:
                state.navigation = .outside(.chat)
                
            case .main:
                state.navigation = .outside(.main)
                
            case .payments:
                state.navigation = .outside(.payments)
                
            case .qr:
                state.navigation = .outside(.qr)
            }
            
        case let .provider(provider):
            state.isLoading = true
            effect = .select(.provider(provider))
        }
    }
}
