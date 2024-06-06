//
//  AnywayPaymentReducer.swift
//
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain
import ForaTools
import Foundation
import Tagged

public final class AnywayPaymentReducer {
    
    public init() {}
}

public extension AnywayPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .setValue(value, for: parameterID):
            reduce(&state, value, parameterID)
            
        case let .widget(widget):
            reduce(&state, widget)
        }
        
        return (state, nil)
    }
}

public extension AnywayPaymentReducer {
    
    typealias State = AnywayPayment
    typealias Event = AnywayPaymentEvent
    typealias Effect = AnywayPaymentEffect
}

private extension AnywayPaymentReducer {
    
    func reduce(
        _ state: inout State,
        _ value: String,
        _ parameterID: Event.ParameterID
    ) {
        state.setValue(value, for: parameterID)
    }
    
    func reduce(
        _ state: inout State,
        _ widget: Event.Widget
    ) {
        switch widget {
        case let .amount(amount):
            state.update(with: amount)
            
        case let .otp(otp):
            let digits = otp.filter(\.isWholeNumber)
            state.update(otp: .init(digits.prefix(6)))
            
        case let .product(productID, currency):
            state.update(with: productID, and: currency)
        }
    }
}

private extension AnywayPayment {
    
    mutating func setValue(
        _ value: String,
        for parameterID: ParameterID
    ) {
        guard let index = elements.firstIndex(matching: parameterID),
              case let .parameter(parameter) = elements[index]
        else { return }
        
        elements[index] = .parameter(parameter.updating(value: value))
    }
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
    
    mutating func update(
        with amount: Decimal
    ) {
        guard let index = elements.firstIndex(matching: .core),
              case let .widget(.core(core)) = elements[index]
        else { return }
        
        elements[index] = .widget(.core(core.updating(amount: amount)))
    }
    
    mutating func update(
        with productID: Element.Widget.PaymentCore.ProductID,
        and currency: Element.Widget.PaymentCore.Currency
    ) {
        guard let index = elements.firstIndex(matching: .core),
              case let .widget(.core(core)) = elements[index]
        else { return }
        
        elements[index] = .widget(.core(core.updating(with: productID, and: currency)))
    }
    
    mutating func update(
        otp: Int?
    ) {
        guard let index = elements.firstIndex(matching: .otp),
              case .widget(.otp) = elements[index]
        else { return }
        
        elements[index] = .widget(.otp(otp))
    }
}

private extension AnywayPayment.Element.Parameter {
    
    func updating(value: String?) -> Self {
        
        .init(
            field: .init(id: field.id, value: value.map { .init($0) }),
            image: image,
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}

private extension AnywayPayment.Element.Widget.PaymentCore {
    
    func updating(
        amount: Decimal
    ) -> Self {
        return .init(amount: amount, currency: currency, productID: productID)
    }
    
    func updating(
        with productID: ProductID,
        and currency: Currency
    ) -> Self {
        
        return .init(amount: amount, currency: currency, productID: productID)
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    func firstIndex(matching id: ParameterID) -> Index? {
        
        firstIndex {
            
            switch $0 {
            case let .parameter(parameter):
                return parameter.field.id == id
                
            default:
                return false
            }
        }
    }
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
    
    func firstIndex(matching id: Element.Widget.ID) -> Index? {
        
        firstIndex {
            
            switch $0 {
            case let .widget(widget):
                return widget.id == id
                
            default:
                return false
            }
        }
    }
}
