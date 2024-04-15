//
//  AnywayPaymentReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import ForaTools

final class AnywayPaymentReducer {
    
    private let makeOTP: MakeOTP
    
    init(makeOTP: @escaping MakeOTP) {
        
        self.makeOTP = makeOTP
    }
}

extension AnywayPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        let effect: Effect? = nil
        
        switch event {
        case let .otp(otp):
            state.elements[id: .widgetID(.otp)] = .widget(.otp(makeOTP(otp)))
            
        case let .setValue(newValue, for: parameterID):
            let parameterValue = ParameterValue(rawValue: newValue)
            state.elements.set(value: parameterValue, for: parameterID)
        }
        
        return (state, effect)
    }
}

extension AnywayPaymentReducer {
    
    typealias MakeOTP = (String) -> Int?
    
    typealias ParameterValue = AnywayPayment.Element.Parameter.Field.Value
    
    typealias State = AnywayPayment
    typealias Event = AnywayPaymentEvent
    typealias Effect = AnywayPaymentEffect
}

private extension Array where Element == AnywayPayment.Element {
    
    mutating func set(
        value newValue: Element.Parameter.Field.Value,
        for id: Element.Parameter.Field.ID
    ) {
        guard let index = firstIndex(matching: .parameterID(id)),
              case let .parameter(parameter) = self[index],
              id == parameter.field.id
        else { return }
        
        self[index] = .parameter(parameter.updating(value: newValue))
    }
}

private extension Array where Element: Identifiable {
    
    func firstIndex(matching id: Element.ID) -> Index? {
        
        firstIndex(where: { $0.id == id})
    }
}

private extension AnywayPayment.Element.Parameter {
    
    func updating(value newValue: Field.Value) -> Self {
        
        .init(
            field: .init(id: field.id, value: newValue),
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}
