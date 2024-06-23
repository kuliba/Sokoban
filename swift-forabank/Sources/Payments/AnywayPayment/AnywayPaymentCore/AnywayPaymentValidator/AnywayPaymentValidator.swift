//
//  AnywayPaymentValidator.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentDomain

public final class AnywayPaymentValidator {
    
    private let validateParameter: ValidateParameter
    
    public init(
        validateParameter: @escaping ValidateParameter
    ) {
        self.validateParameter = validateParameter
    }
}

public extension AnywayPaymentValidator {
    
    @available(*, deprecated, message: "Use `validate(_:)`")
    func isValid(_ payment: Payment) -> Bool {
        
        return validate(payment) == nil
    }
        
    func validate(
        _ payment: Payment
    ) -> AnywayPaymentValidationError? {
        
        guard isValid(payment.footer) else { return .footerValidationError }
        
        guard !payment.parameters.isEmpty else { return nil }
        
        let errors = validate(payment.parameters)
        
        return errors.isEmpty ? nil : .parameterValidationErrors(errors)
    }
}

public extension AnywayPaymentValidator {
    
    typealias ValidateParameter = (Parameter) -> AnywayPaymentParameterValidationError?
    
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
    
    func validate(
        _ parameters: [Parameter]
    ) -> AnywayPaymentValidationError.Errors {
        
        let errors = parameters.compactMap { parameter in
            
            validateParameter(parameter).map { (parameter.field.id, $0) }
        }
        
        return .init(errors, uniquingKeysWith: { _, last in last })
    }

    typealias ID = Parameter.Field.ID
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
