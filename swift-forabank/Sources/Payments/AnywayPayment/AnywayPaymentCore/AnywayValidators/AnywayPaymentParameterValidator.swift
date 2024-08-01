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
        
        let validationErrors = [
            validateRequired(parameter),
            validateMaxLength(parameter),
            validateMinLength(parameter),
            validateRegExp(parameter),
        ].compactMap { $0 }
        
        return validationErrors.first
    }
}

public extension AnywayPaymentParameterValidator {
    
    typealias Parameter = AnywayElement.Parameter
}

private extension AnywayPaymentParameterValidator {
    
    func validateRequired(
        _ parameter: Parameter
    ) -> AnywayPaymentParameterValidationError? {
        
        if parameter.validation.isRequired,
           parameter.field.value == nil {
            
            return .emptyRequired
        } else {
            return nil
        }
    }
    
    func validateMinLength(
        _ parameter: Parameter
    ) -> AnywayPaymentParameterValidationError? {
        
        guard let minLength = parameter.validation.minLength else { return nil }
        
        let value = parameter.field.value ?? ""
        
        return value.count >= minLength ? nil : .tooShort
    }
    
    func validateMaxLength(
        _ parameter: Parameter
    ) -> AnywayPaymentParameterValidationError? {
        
        guard let maxLength = parameter.validation.maxLength else { return nil }
        
        let value = parameter.field.value ?? ""
        
        return value.count <= maxLength ? nil : .tooLong
    }
    
    func validateRegExp(
        _ parameter: Parameter
    ) -> AnywayPaymentParameterValidationError? {
        
        guard !parameter.validation.regExp.isEmpty else { return nil }
        
        let value = parameter.field.value ?? ""
        let pattern = parameter.validation.regExp
        let isMatching = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
        
        return isMatching ? nil : .regExViolation
    }
}
