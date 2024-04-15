//
//  AnywayPaymentReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import ForaTools
import Foundation

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
        case .pay:
#warning("should belong to transaction level event")
            break
            
        case let .setValue(newValue, for: parameterID):
            state.elements.set(value: .init(newValue), for: parameterID)
            
        case let .widget(widget):
            reduce(&state, with: widget)
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

private extension AnywayPaymentReducer {
    
    func reduce(
        _ state: inout State,
        with event: AnywayPaymentEvent.Widget
    ) {
        switch event {
        case let .amount(amount):
            state.elements.updating(coreAmount: amount)
            
        case let .otp(otp):
            state.elements[id: .widgetID(.otp)] = .widget(.otp(makeOTP(otp)))
            
        case let .product(productID, currency):
            state.elements.updating(productID: productID, currency: currency)
        }
    }
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
    
    mutating func updating(coreAmount amount: Decimal) {
        
        guard case let .widget(.core(core)) = self[id: .widgetID(.core)]
        else { return }
        
        self[id: .widgetID(.core)] = .widget(.core(core.updating(amount: amount)))
    }
    
    mutating func updating(
        productID: Element.Widget.PaymentCore.ProductID,
        currency: Element.Widget.PaymentCore.Currency
    ) {
        guard case let .widget(.core(core)) = self[id: .widgetID(.core)]
        else { return }
        
        let updated = core.updating(productID: productID, currency: currency)
        self[id: .widgetID(.core)] = .widget(.core(updated))
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

private extension AnywayPayment.Element.Widget.PaymentCore {
    
    func updating(amount: Decimal) -> Self {
        
        .init(amount: amount, currency: currency, productID: productID)
    }
    
    func updating(
        productID: ProductID,
        currency: Currency
    ) -> Self {
        
        .init(amount: amount, currency: currency, productID: productID)
    }
}
