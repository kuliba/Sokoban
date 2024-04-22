//
//  AnywayPayment.Outline+update.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

extension AnywayPayment.Outline {
    
    public func update(with payment: AnywayPayment) -> Self {
        
        let fields = fields.merging(
            payment.elements.compactMap(\.idValuePair),
            uniquingKeysWith: { _, new in new }
        )
        
        return .init(core: core, fields: fields)
    }
}

private extension AnywayPayment.Element {
    
    var idValuePair: (AnywayPayment.Outline.ID, AnywayPayment.Outline.Value)? {
        
        guard case let .parameter(parameter) = self,
              parameter.isOutlinable
        else { return nil }
        
        return parameter.field.value.map {
            
            (.init(parameter.field.id.rawValue), .init($0.rawValue))
        }
    }
}

private extension AnywayPayment.Element.Parameter {

    var isOutlinable: Bool {
        
        uiAttributes.viewType == .input
    }
}
