//
//  AnywayPayment.Outline+update.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

extension AnywayPayment.Outline {
    
    public func update(with payment: AnywayPayment) -> Self {
        
        let fields = fields.merging(
            payment.elements.compactMap(\.parameterIDValuePair),
            uniquingKeysWith: { _, new in new }
        )
        
        return .init(core: core, fields: fields)
    }
}

private extension AnywayPayment.Element {
    
    var parameterIDValuePair: (StringID, Value)? {
        
        guard case let .parameter(parameter) = self
        else { return nil }
        
        return parameter.field.value.map { (parameter.field.id, $0 ) }
    }
}
