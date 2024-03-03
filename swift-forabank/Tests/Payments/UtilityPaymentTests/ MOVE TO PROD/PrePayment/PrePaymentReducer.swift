//
//  PrePaymentReducer.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

final class PrePaymentReducer {
    
}

extension PrePaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch (state, event) {
        case (.selecting, .addCompany):
            state = .addingCompany
            
        case (.selecting, .payByInstruction):
            state = .payingByInstruction
            
        case (.selecting, .scan):
            state = .scanning
            
        case let (.selecting, .select(select)):
            switch select {
            case let .last(lastPayment):
                state = .selected(.last(lastPayment))
                
            case let .operator(`operator`):
                state = .selected(.operator(`operator`))
            }
            
        default:
            break
        }
        
        return (state, nil)
    }
}

extension PrePaymentReducer {
    
    typealias State = PrePaymentState
    typealias Event = PrePaymentEvent
    typealias Effect = PrePaymentEffect
}
