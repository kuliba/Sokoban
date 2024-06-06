//
//  Payment.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 04.06.2024.
//

import RxViewModel

typealias PaymentViewModel = RxViewModel<Payment, PaymentEvent, PaymentEffect>

struct Payment: Equatable {
    
    var elements: [Element]
}

extension Payment {
    
    enum Element: Equatable {
        
        case field(Field)
        case param(Param)
    }
}

extension Payment.Element: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .field(field): return .field(field.id)
        case let .param(param): return .param(param.id)
        }
    }
    
    enum ID: Hashable {
        
        case field(String)
        case param(String)
    }
}

extension Payment.Element {
    
    struct Field: Equatable, Identifiable {
        
        let id: ID
        let title: String
        var value: Value
        
        typealias ID = String
        typealias Value = String
    }
    
    struct Param: Equatable, Identifiable {
        
        let id: String
        let title: String
        let subtitle: String
        var value: String
    }
}

enum PaymentEvent {
    
    case addField(Payment.Element.Field)
    case addParam(Payment.Element.Param)
    case set(value: String, forID: Payment.Element.ID)
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
        case let .addField(field):
            state.elements.append(.field(field))
            
        case let .addParam(param):
            state.elements.append(.param(param))
            
        case let .set(value: value, forID: id):
            guard let index = state.elements.firstIndex(where: { $0.id == id })
            else { break }
            
            let element = state.elements[index]
            
            switch element {
            case var .field(field):
                field.value = value
                state.elements[index] = .field(field)
                
            case var .param(param):
                param.value = value
                state.elements[index] = .param(param)
            }
        }
        
        return (state, nil)
    }
}

extension PaymentReducer {
    
    typealias State = Payment
    typealias Event = PaymentEvent
    typealias Effect = PaymentEffect
}
