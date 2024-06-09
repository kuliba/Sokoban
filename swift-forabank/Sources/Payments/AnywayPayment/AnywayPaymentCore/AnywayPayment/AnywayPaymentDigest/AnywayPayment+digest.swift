//
//  AnywayPayment+makeDigest.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentDomain

public extension AnywayPayment {
    
    func makeDigest() -> AnywayPaymentDigest {
        
        return .init(
            additional: additional(),
            core: core(),
            puref: .init(puref.rawValue)
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
        
        guard case let .widget(.core(core)) = elements.first(where: { $0.widget?.id == .core })
        else { return nil}
        
        return .init(
            amount: core.amount,
            currency: .init(core.currency),
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

private extension AnywayElement.Widget.PaymentCore {
    
    var _productType: AnywayPaymentDigest.PaymentCore.ProductType {
        
        switch productType {
        case .account: return .account
        case .card:    return .card
        }
    }
}
