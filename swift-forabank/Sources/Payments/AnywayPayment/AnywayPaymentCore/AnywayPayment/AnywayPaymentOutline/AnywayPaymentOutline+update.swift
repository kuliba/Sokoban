//
//  AnywayPaymentOutline+updating.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentDomain

extension AnywayPaymentOutline {
    
    public func updating(with payment: AnywayPayment) -> Self {
        
        let fields = fields.merging(
            payment.elements.compactMap(\.idValuePair),
            uniquingKeysWith: { _, new in new }
        )
        
        return .init(core: core, fields: fields, payload: payload)
    }
}

private extension AnywayElement {
    
    var idValuePair: (AnywayPaymentOutline.ID, AnywayPaymentOutline.Value)? {
        
        guard case let .parameter(parameter) = self,
              parameter.isOutlinable
        else { return nil }
        
        return parameter.field.value.map {
            
            (parameter.field.id, $0)
        }
    }
}

private extension AnywayElement.Parameter {
    
    var isOutlinable: Bool {
        
        uiAttributes.viewType == .input
    }
}
