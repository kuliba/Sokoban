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
        
        guard !payment.parameters.isEmpty else { return true }
        
        return payment.parameters.allSatisfy(isValidParameter)
    }
}

public extension AnywayPaymentValidator {
    
    typealias IsValidParameter = (Parameter) -> Bool
    
    typealias Payment = AnywayPayment
    typealias Parameter = AnywayPayment.AnywayElement.Parameter
}

private extension AnywayPayment {
    
    var parameters: [AnywayElement.Parameter] { elements.compactMap(\.parameter) }
}

private extension AnywayPayment.AnywayElement {
    
    var parameter: Parameter? {
        
        guard case let .parameter(parameter) = self else { return nil }
        
        return parameter
    }
}
