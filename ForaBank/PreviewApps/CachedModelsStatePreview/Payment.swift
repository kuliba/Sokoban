//
//  Payment.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 04.06.2024.
//

import RxViewModel

typealias PaymentViewModel = RxViewModel<Payment, PaymentEvent, PaymentEffect>

struct Payment: Equatable {
    
    var fields: [Field]
}

extension Payment {
    
    struct Field: Equatable, Identifiable {
        
        let id: ID
        let title: String
        var value: Value
        
        typealias ID = String
        typealias Value = String
    }
}

enum PaymentEvent {
    
    case add(Field)
    case set(value: Value, forID: ID)
    
    typealias Field = Payment.Field
    typealias ID = Field.ID
    typealias Value = Field.Value
}

enum PaymentEffect: Equatable {}

final class PaymentReducer {}

extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .add(field):
            state.fields.append(field)
            
        case let .set(value: value, forID: id):
            guard let index = state.fields.firstIndex(where: { $0.id == id })
            else { break }
            
            var field = state.fields[index]
            field.value = value
            state.fields[index] = field
        }
        
        return (state, nil)
    }
}

extension PaymentReducer {
    
    typealias State = Payment
    typealias Event = PaymentEvent
    typealias Effect = PaymentEffect
}
