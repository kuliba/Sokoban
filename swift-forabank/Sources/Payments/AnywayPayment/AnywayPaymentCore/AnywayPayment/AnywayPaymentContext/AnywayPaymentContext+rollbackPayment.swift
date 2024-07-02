//
//  AnywayPaymentContext+rollbackPayment.swift
//
//
//  Created by Igor Malyarov on 28.05.2024.
//

import AnywayPaymentDomain

public extension AnywayPaymentContext {
    
    func rollbackPayment() -> Self {
        
        guard !staged.isEmpty else { return self }
        
        return updating(payment: payment.rollback(with: snapshot))
    }
}

private extension AnywayPaymentContext {
    
    func updating(payment: AnywayPayment) -> Self {
        
        return .init(
            initial: initial,
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
            
            staged.contains(field.key) ? (field.key, field.value): nil
        }
    }
    
    typealias Pair = (AnywayElement.Parameter.Field.ID, AnywayElement.Parameter.Field.Value)
}

private typealias Snapshot = [AnywayElement.Parameter.Field.ID: AnywayElement.Parameter.Field.Value]

private extension AnywayPayment {
    
    func rollback(with snapshot: Snapshot) -> Self {
        
        let elements = elements.map { $0.rollback(with: snapshot) }
#warning("add tests")
        let footer = footer.rollback(with: snapshot)
        return updating(with: elements, and: footer)
    }
    
    func updating(
        with elements: [AnywayElement],
        and footer: Footer
    ) -> Self {
        
        return .init(
            amount: amount,
            elements: elements,
            footer: footer,
            isFinalStep: isFinalStep
        )
    }
}

private extension AnywayElement {
    
    func rollback(with snapshot: Snapshot) -> Self {
        
        switch self {
        case let .parameter(parameter):
            return .parameter(parameter.rollback(with: snapshot))
            
        default:
            return self
        }
    }
}

private extension Payment.Footer {
    
#warning("FIXME add tests")
    func rollback(with snapshot: Snapshot) -> Self {
        
        self
    }
}

private extension AnywayElement.Parameter {
    
    func rollback(with snapshot: Snapshot) -> Self {
        
        guard let snapshottedValue = snapshot[field.id] else { return self }
        
        return updating(value: snapshottedValue)
    }
    
    func updating(
        value: AnywayElement.Parameter.Field.Value
    ) -> Self {
        
        return .init(
            field: .init(id: field.id, value: value),
            icon: icon,
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}
