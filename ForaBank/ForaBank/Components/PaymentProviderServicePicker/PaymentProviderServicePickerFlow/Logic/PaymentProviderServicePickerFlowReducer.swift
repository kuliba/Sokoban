//
//  PaymentProviderServicePickerFlowReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

final class PaymentProviderServicePickerFlowReducer {}

extension PaymentProviderServicePickerFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismissDestination:
            state.destination = nil
            
        case .payByInstructionTap:
            guard state.destination == nil
            else { break }
            
            effect = .payByInstruction
            
        case let .payByInstruction(paymentsViewModel):
            guard state.destination == nil
            else { break }
            
            state.destination = .paymentByInstruction(paymentsViewModel)
        }
        
        return (state, effect)
    }
}

extension PaymentProviderServicePickerFlowReducer {
    
    typealias State = PaymentProviderServicePickerFlowState
    typealias Event = PaymentProviderServicePickerFlowEvent
    typealias Effect = PaymentProviderServicePickerFlowEffect
}
