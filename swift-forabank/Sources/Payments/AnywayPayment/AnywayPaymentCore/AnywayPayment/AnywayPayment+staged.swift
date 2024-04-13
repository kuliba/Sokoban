//
//  AnywayPayment+staged.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import Tagged

extension AnywayPayment {
    
    public func staged() -> Staged {
        
        .init(elements.compactMap(\.parameterID))
    }

    public typealias Staged = Set<AnywayPayment.Element.Parameter.Field.ID>
}

private extension AnywayPayment.Element {
    
    var parameterID: AnywayPayment.Element.Parameter.Field.ID? {
        
        guard case let .parameter(parameter) = self
        else { return nil }
        
        return parameter.field.id
    }
}
