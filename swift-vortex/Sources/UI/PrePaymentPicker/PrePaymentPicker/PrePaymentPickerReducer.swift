//
//  PrePaymentPickerReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class PrePaymentPickerReducer<LastPayment, Operator>
where Operator: Identifiable {
    
    private let optionsReduce: OptionsReduce
    
    public init(optionsReduce: @escaping OptionsReduce) {
        
        self.optionsReduce = optionsReduce
    }
}

public extension PrePaymentPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (state, event) {
        case let (.options(optionsState), .options(optionsEvent)):
            let (newOptionsState, optionsEffect) = optionsReduce(optionsState, optionsEvent)
            state = .options(newOptionsState)
            effect = optionsEffect.map(Effect.options)
            
        case let (.options, .select(selectEvent)):
            switch selectEvent {
            case let .lastPayment(lastPayment):
                state = .selected(.lastPayment(lastPayment))
                
            case let .operator(`operator`):
                state = .selected(.operator(`operator`))
            }
            
        default:
            break
        }
        
        return (state, effect)
    }
}

public extension PrePaymentPickerReducer {
    
    typealias OptionsState = PrePaymentOptionsState<LastPayment, Operator>
    typealias OptionsEvent =  PrePaymentOptionsEvent<LastPayment, Operator>
    typealias OptionsEffect = PrePaymentOptionsEffect<Operator>
    
    typealias OptionsReduce = (OptionsState, OptionsEvent) -> (OptionsState, OptionsEffect?)
    
    typealias State = PrePaymentPickerState<LastPayment, Operator>
    typealias Event = PrePaymentPickerEvent<LastPayment, Operator>
    typealias Effect = PrePaymentPickerEffect<Operator>
}
