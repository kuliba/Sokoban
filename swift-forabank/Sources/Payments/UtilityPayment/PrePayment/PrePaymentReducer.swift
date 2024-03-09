//
//  PrePaymentReducer.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

public final class PrePaymentReducer<LastPayment, Operator> {
    
    public init() {}
}

public extension PrePaymentReducer {
    
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
            
        case (_, .back):
            state = .selecting
            
        default:
            break
        }
        
        return (state, nil)
    }
}

public extension PrePaymentReducer {
    
    typealias State = PrePaymentState<LastPayment, Operator>
    typealias Event = PrePaymentEvent<LastPayment, Operator>
    typealias Effect = PrePaymentEffect
}
