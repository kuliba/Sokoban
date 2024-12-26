//
//  AnywayPaymentParameterValidator.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentDomain
import VortexTools
import Foundation

public final class AnywayPaymentParameterValidator {
    
    public init() {}
}

public extension AnywayPaymentParameterValidator {
    
    @inlinable
    func isValid(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> Bool {
        
        return validate(value, with: validation) == nil
    }
    
    @inlinable
    func validate(
        _ parameter: Parameter
    ) -> AnywayPaymentParameterValidationError? {
        
        switch parameter.uiAttributes.type {
            
        case .checkbox:
            return validateCheckbox(
                parameter.field.value,
                with: parameter.validation
            )
            
        default:
            return validate(
                parameter.field.value,
                with: parameter.validation
            )
        }
    }
    
    @inlinable
    func validateCheckbox(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        let eligible = validation.isRequired ? ["1"] : [nil, "", "0", "1"]

        return eligible.contains(value) ? nil : .invalidCheckbox
    }
    
    @inlinable
    func validate(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        let validationErrors = [
            validateEmptyRequired(value, with: validation),
            validateMaxLength(value, with: validation),
            validateMinLength(value, with: validation),
            validateRegExp(value, with: validation),
        ]
        
        return validationErrors.compactMap { $0 }.first
    }
}

public extension AnywayPaymentParameterValidator {
    
    typealias Parameter = AnywayElement.Parameter
}

private extension Optional where Wrapped == String {
    
    var isNilOrEmpty: Bool {
        
        guard let string = self else { return true }
        
        return string.isEmpty
    }
}

extension AnywayPaymentParameterValidator {
    
    @usableFromInline
    func validateEmptyRequired(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        if validation.isRequired, value.isNilOrEmpty {
            return .emptyRequired
        } else {
            return nil
        }
    }
    
    @usableFromInline
    func validateMinLength(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        guard let minLength = validation.minLength else { return nil }
        
        let value = value ?? ""
        
        switch (value.count, validation.isRequired) {
            
        case (0, false):
            return nil
            
        default:
            return value.count >= minLength ? nil : .tooShort
        }
    }
    
    @usableFromInline
    func validateMaxLength(
        _ value: String?,
        with validation: Parameter.Validation
    ) -> AnywayPaymentParameterValidationError? {
        
        guard let maxLength = validation.maxLength else { return nil }
        
        let value = value ?? ""
        
        return value.count <= maxLength ? nil : .tooLong
    }
    
    @usableFromInline
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
