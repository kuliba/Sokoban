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
            
        case let .otpWarning(warning):
            state.update(otpWarning: warning)
            
        case let .product(productID, productType, currency):
            state.update(with: productID, productType._productType, and: currency)
        }
    }
}

private extension AnywayPaymentEvent.Widget.ProductType {
    
    var _productType: AnywayElement.Widget.Product.ProductType {
        
        switch self {
        case .account: return .account
        case .card:    return .card
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
    
    typealias ParameterID = AnywayElement.Parameter.Field.ID
    
    mutating func update(
        with amount: Decimal
    ) {
#warning("add tests")
        guard case .amount = footer else { return }
        
        footer = .amount(amount)
    }
    
    mutating func update(
        with productID: AnywayElement.Widget.Product.ProductID,
        _ productType: AnywayElement.Widget.Product.ProductType,
        and currency: AnywayElement.Widget.Product.Currency
    ) {
        guard let index = elements.firstIndex(matching: .product),
              case let .widget(.product(core)) = elements[index]
        else { return }
        
        elements[index] = .widget(.product(core.updating(with: productID, productType, and: currency)))
    }
    
    mutating func update(
        otp: Int?
    ) {
        guard let index = elements.firstIndex(matching: .otp),
              case .widget(.otp) = elements[index]
        else { return }
        
        elements[index] = .widget(.otp(otp, nil))
    }
    
    mutating func update(
        otpWarning warning: String?
    ) {
        guard let index = elements.firstIndex(matching: .otp),
              case let .widget(.otp(otp, _)) = elements[index]
        else { return }
        
        elements[index] = .widget(.otp(otp, warning))
    }
}

private extension AnywayElement.Parameter {
    
    func updating(value: String?) -> Self {
        
        return .init(
            field: .init(id: field.id, value: value),
            icon: icon,
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}

private extension AnywayElement.Widget.Product {
    
    func updating(
        with productID: ProductID,
        _ productType: ProductType,
        and currency: Currency
    ) -> Self {
        
        return .init(currency: currency, productID: productID, productType: productType)
    }
}

private extension Array where Element == AnywayElement {
    
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
    
    typealias ParameterID = AnywayElement.Parameter.Field.ID
    
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
