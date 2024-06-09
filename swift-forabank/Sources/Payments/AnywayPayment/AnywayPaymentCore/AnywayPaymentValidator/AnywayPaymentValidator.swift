//
//  AnywayPaymentValidator.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentDomain

public final class AnywayPaymentValidator {
    
    private let isValidParameter: IsValidParameter
    
    public init(
        isValidParameter: @escaping IsValidParameter
    ) {
        self.isValidParameter = isValidParameter
    }
}

public extension AnywayPaymentValidator {
    
    func isValid(_ payment: Payment) -> Bool {
        
        guard isValid(payment.footer) else { return false }
        
        guard !payment.parameters.isEmpty else { return true }
        
        return payment.parameters.allSatisfy(isValidParameter)
    }
}

public extension AnywayPaymentValidator {
    
    typealias IsValidParameter = (Parameter) -> Bool
    
    typealias Payment = AnywayPayment
    typealias Parameter = AnywayElement.Parameter
}

private extension AnywayPaymentValidator {
    
    func isValid(
        _ footer: Payment.Footer
    ) -> Bool {
        
        switch footer {
        case let .amount(amount):
            return amount > 0
            
        case .continue:
            return true
        }
    }
}

// MARK: - Helpers

private extension AnywayPayment {
    
    var parameters: [AnywayElement.Parameter] { elements.compactMap(\.parameter) }
}

private extension AnywayElement {
    
    var parameter: Parameter? {
        
        guard case let .parameter(parameter) = self else { return nil }
        
        return parameter
    }
}
