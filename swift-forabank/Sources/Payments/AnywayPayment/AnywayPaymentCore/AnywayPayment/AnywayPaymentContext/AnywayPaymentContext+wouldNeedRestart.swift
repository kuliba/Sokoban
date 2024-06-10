//
//  AnywayPaymentContext+wouldNeedRestart.swift
//
//
//  Created by Igor Malyarov on 28.05.2024.
//

import AnywayPaymentDomain

public extension AnywayPaymentContext {
    
    var wouldNeedRestart: Bool {
        
        guard stagedPaymentPairs.keys == stagedOutlinedPairs.keys
        else { return false }
        
        let hasSameValues = stagedPaymentPairs.keys.allSatisfy { key in
            
            stagedPaymentPairs[key] == stagedOutlinedPairs[key]
        }
        
        return !hasSameValues
    }
}

private extension AnywayPaymentContext {
    
    var stagedOutlinedPairs: Pairs {
        
        outline.fields
            .filter { staged.contains($0.key) }
            .mapValues(Optional<AnywayPaymentOutline.Value>.init)
    }
    
    var stagedPaymentPairs: Pairs {
        
        let parameterFieldPairs = payment.elements.parameterFields
            .map { field -> (AnywayPaymentOutline.ID, AnywayPaymentOutline.Value?) in
                
                return (field.id, field.value.map { $0 })
            }
        
        let dict = Dictionary(parameterFieldPairs) { _, last in last}
        
        return dict.filter { staged.contains($0.key) }
    }
    
    typealias Pairs = [AnywayPaymentOutline.ID : AnywayPaymentOutline.Value?]
}

private extension Array where Element == AnywayElement {
    
    var parameterFields: [AnywayElement.Parameter.Field] {
        
        compactMap {
            
            guard case let .parameter(parameter) = $0 else { return nil }
            
            return parameter.field
        }
    }
}
