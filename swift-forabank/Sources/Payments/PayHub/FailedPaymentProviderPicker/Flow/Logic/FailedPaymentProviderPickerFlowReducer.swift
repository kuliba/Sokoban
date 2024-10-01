//
//  FailedPaymentProviderPickerFlowReducer.swift
//  
//
//  Created by Igor Malyarov on 23.09.2024.
//

public final class FailedPaymentProviderPickerFlowReducer<Destination> {
    
    public init() {}
}

public extension FailedPaymentProviderPickerFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .destination(destination):
            state.destination = destination
            
        case .resetDestination:
            state.destination = nil
            
        case .select(.detailPay):
            effect = .select(.detailPay)
        }
        
        return (state, effect)
    }
}

public extension FailedPaymentProviderPickerFlowReducer {
    
    typealias State = FailedPaymentProviderPickerFlowState<Destination>
    typealias Event = FailedPaymentProviderPickerFlowEvent<Destination>
    typealias Effect = FailedPaymentProviderPickerFlowEffect
}
