//
//  AnywayPayment.Outline+update.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

extension AnywayPayment.Outline {
    
    public func update(with payment: AnywayPayment) -> Self {
        
        merging(
            payment.elements.compactMap(\.parameterIDValuePair),
            uniquingKeysWith: { first, _ in first }
        )
    }
}

private extension AnywayPayment.Element {
    
    var parameterIDValuePair: (StringID, Value)? {
        
        guard case let .parameter(parameter) = self
        else { return nil }
        
        return parameter.field.value.map { (parameter.field.id, $0 ) }
    }
}
