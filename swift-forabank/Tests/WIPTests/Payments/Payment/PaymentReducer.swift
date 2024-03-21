//
//  PaymentReducer.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

final class PaymentReducer {
    
    let parameterReduce: ParameterReduce
    
    init(parameterReduce: ParameterReduce) {
        
        self.parameterReduce = parameterReduce
    }
}

extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .parameter(paymentParameterEvent):
            (state, effect) = reduce(state, paymentParameterEvent)
        }
        
        return (state, effect)
    }
}

extension PaymentReducer {
    
    typealias State = Payment
    typealias Event = PaymentEvent
    typealias Effect = PaymentEffect
}

extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: PaymentParameterEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .input(inputParameterEvent):
            if case let .input(inputParameter) = state[.input] {
                
                let (s, e) = parameterReduce.inputReduce(inputParameter, inputParameterEvent)
                state[.input] = .input(s)
                effect = e.map { .parameter(.input($0)) }
            }
            
        case let .select(selectParameterEvent):
            if case let .select(selectParameter) = state[.select] {
                
                let (s, e) = parameterReduce.selectReduce(selectParameter, selectParameterEvent)
                state[.select] = .select(s)
                effect = e.map { .parameter(.select($0)) }
            }
        }
        
        return (state, effect)
    }
}

extension Payment {
    
    subscript(id: PaymentParameter.ID) -> PaymentParameter? {
        
        get { parameters.first { $0.id == id } }
        
        set(newValue) {
            
            guard let newValue,
                  let index = parameters.firstIndex(where: { $0.id == id })
            else { return }
            
            parameters[index] = newValue
        }
    }
}
