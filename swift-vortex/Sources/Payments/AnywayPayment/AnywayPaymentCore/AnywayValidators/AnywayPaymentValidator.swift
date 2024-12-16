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
    
    /// Validates the provided payment.
    ///
    /// - Parameter payment: The payment to be validated.
    /// - Returns: An optional `AnywayPaymentValidationError`. If the payment is valid, returns `nil`. If there are parameter validation errors, returns `.parameterValidationErrors(errors)`. If the parameters are valid, it then validates the footer. If the footer is invalid, returns `.footerValidationError`.
    func validate(
        _ payment: AnywayPayment
    ) -> AnywayPaymentValidationError? {
        
        let errors = validate(payment.parameters)
        
        if !errors.isEmpty {
            
            return .parameterValidationErrors(errors)
        }
        
        return validateOTP(payment) ?? validateAmount(payment)
    }
}

public extension AnywayPaymentValidator {
    
    typealias ValidateParameter = (Parameter) -> AnywayPaymentParameterValidationError?
    
    typealias Parameter = AnywayElement.Parameter
}

private extension AnywayPaymentValidator {
    
    func validateOTP(
        _ payment: AnywayPayment
    ) -> AnywayPaymentValidationError? {
        
        guard let widget = payment.elements.first(where: { $0.id == .widgetID(.otp) }),
              case let .widget(.otp(otp, _)) = widget
        else { return nil }
        
        guard let string = otp.map({ "\($0)" }),
              string.count == 6
        else { return .otpValidationError }
        
        return nil
    }
    
    func validateAmount(
        _ payment: AnywayPayment
    ) -> AnywayPaymentValidationError? {
        
        guard case .amount = payment.footer
        else { return nil }
        
        return (payment.amount ?? -1) > 0 ? nil : .footerValidationError
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
