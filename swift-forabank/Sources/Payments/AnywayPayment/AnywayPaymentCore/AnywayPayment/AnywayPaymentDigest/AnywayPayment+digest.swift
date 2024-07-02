//
//  AnywayPayment+makeDigest.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentDomain
import Foundation

public extension AnywayPaymentContext {
    
    func makeDigest() -> AnywayPaymentDigest {
        
        guard !shouldRestart
        else {
            // TODO: add tests
            return .init(
                additional: [], 
                amount: nil,
                core: nil,
                puref: outline.payload.puref
            )
        }
        
        return .init(
            additional: payment.additional(),
            amount: payment.amount,
            core: payment.core(),
            puref: outline.payload.puref
        )
    }
}

private extension AnywayPayment {
    
    func additional() -> [AnywayPaymentDigest.Additional] {
        
        fields.enumerated().compactMap { index, field in
            
            field.value.map {
                
                .init(fieldID: index, fieldName: field.id, fieldValue: $0)
            }
        }
    }
    
    func core() -> AnywayPaymentDigest.PaymentCore? {
        
        guard case let .widget(.product(core)) = elements.first(where: { $0.widget?.id == .product })
        else { return nil}
        
        return .init(
            currency: core.currency,
            productID: core.productID,
            productType: core._productType
        )
    }
    
    var fields: [AnywayElement.Parameter.Field] {
        
        elements.compactMap(\.parameter?.field)
    }
}

private extension AnywayElement {
    
    var parameter: Parameter? {
        
        guard case let .parameter(parameter) = self else { return nil }
        
        return parameter
    }
    
    var widget: Widget? {
        
        guard case let .widget(widget) = self else { return nil }
        
        return widget
    }
}

private extension AnywayElement.Widget.Product {
    
    var _productType: AnywayPaymentDigest.PaymentCore.ProductType {
        
        switch productType {
        case .account: return .account
        case .card:    return .card
        }
    }
}
