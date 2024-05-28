//
//  AnywayPaymentContext+restorePayment.swift
//
//
//  Created by Igor Malyarov on 28.05.2024.
//

import AnywayPaymentDomain

extension AnywayPaymentContext {
    
    public func restorePayment() -> Self {
        
        guard !staged.isEmpty else { return self }
        
        return updating(payment: payment.restoring(with: snapshot))
    }
}

private extension AnywayPaymentContext {
    
    func updating(payment: AnywayPayment) -> Self {
        
        return .init(
            payment: payment,
            staged: staged,
            outline: outline,
            shouldRestart: shouldRestart
        )
    }
    
    var snapshot: Snapshot {
        
        return .init(stagedOutlinedPairs, uniquingKeysWith: { _, last in last })
    }
    
    var stagedOutlinedPairs: [Pair] {
        
        outline.fields.compactMap { field -> Pair? in
            
            guard staged.contains(.init(field.key.rawValue)) else { return nil }
            
            return (.init(field.key.rawValue), .init(field.value.rawValue))
        }
    }
    
    typealias Pair = (AnywayPayment.Element.Parameter.Field.ID, AnywayPayment.Element.Parameter.Field.Value)
}

private typealias Snapshot = [AnywayPayment.Element.Parameter.Field.ID: AnywayPayment.Element.Parameter.Field.Value]

private extension AnywayPayment {
    
    func restoring(with snapshot: Snapshot) -> Self {
        
        let elements = elements.map { $0.restoring(with: snapshot) }
        return updating(elements: elements)
    }
    
    func updating(elements: [Element]) -> Self {
        
        return .init(
            elements: elements,
            infoMessage: infoMessage,
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected,
            puref: puref
        )
    }
}

private extension AnywayPayment.Element {
    
    func restoring(with snapshot: Snapshot) -> Self {
        
        switch self {
        case let .parameter(parameter):
            return .parameter(parameter.restoring(with: snapshot))
            
        default:
            return self
        }
    }
}

private extension AnywayPayment.Element.Parameter {
    
    func restoring(with snapshot: Snapshot) -> Self {
        
        guard let snapshottedValue = snapshot[field.id] else { return self }
        
        return updating(value: snapshottedValue)
    }
    
    func updating(
        value: AnywayPayment.Element.Parameter.Field.Value
    ) -> Self {
        
        return .init(
            field: .init(id: field.id, value: value),
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}
