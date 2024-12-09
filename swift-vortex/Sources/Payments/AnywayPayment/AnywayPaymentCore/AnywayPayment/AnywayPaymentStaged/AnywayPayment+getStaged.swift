//
//  AnywayPayment+getStaged.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentDomain
import Tagged

extension AnywayPayment {
    
    public func getStaged() -> AnywayPaymentStaged {
        
        .init(elements.compactMap(\.parameterID))
    }
}

private extension AnywayElement {
    
    var parameterID: AnywayElement.Parameter.Field.ID? {
        
        guard case let .parameter(parameter) = self
        else { return nil }
        
        return parameter.field.id
    }
}
