//
//  AnywayPayment+snapshotted.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

extension AnywayPayment {
    
    public func snapshotted() -> Outline {
        
        let pairs = elements.compactMap(\.parameterIDValuePair)
        
        return .init(uniqueKeysWithValues: pairs)
    }
}

private extension AnywayPayment.Element {
    
    var parameterIDValuePair: (StringID, Value)? {
        
        guard case let .parameter(parameter) = self
        else { return nil }
        
        return parameter.field.value.map { (parameter.field.id, $0 ) }
    }
}
