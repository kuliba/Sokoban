//
//  AnywayPaymentParameterValidator.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentDomain
import Foundation

public final class AnywayPaymentParameterValidator {
    
    public init() {}
}

public extension AnywayPaymentParameterValidator {
    
    func validate(
        _ parameter: Parameter
    ) -> AnywayPaymentParameterValidationError? {
        
        return validate(
            parameter.field.value,
            with: parameter.validation
        )
    }
        
    func isValid(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> Bool {
        
        return validate(value, with: validation) == nil
    }
        
    func validate(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        let validationErrors = [
            validateRequired(value, with: validation),
            validateMaxLength(value, with: validation),
            validateMinLength(value, with: validation),
            validateRegExp(value, with: validation),
        ].compactMap { $0 }
        
        return validationErrors.first
    }
}

public extension AnywayPaymentParameterValidator {
    
    typealias Parameter = AnywayElement.Parameter
}

private extension AnywayPaymentParameterValidator {
    
    func validateRequired(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        if validation.isRequired, value == nil {
            return .emptyRequired
        } else {
            return nil
        }
    }
    
    func validateMinLength(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        guard let minLength = validation.minLength else { return nil }
        
        let value = value ?? ""
        
        return value.count >= minLength ? nil : .tooShort
    }
    
    func validateMaxLength(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        guard let maxLength = validation.maxLength else { return nil }
        
        let value = value ?? ""
        
        return value.count <= maxLength ? nil : .tooLong
    }
    
    func validateRegExp(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        guard !validation.regExp.isEmpty else { return nil }
        
        let value = value ?? ""
        let pattern = validation.regExp
        let isMatching = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
        
        return isMatching ? nil : .regExViolation
    }
}
