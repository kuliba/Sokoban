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
        
        let value = parameter.valueForRegex
        let pattern = parameter.validation.regExp
        let isMatching = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
        
        return isMatching ? nil : .regExViolation
    }
}

private extension AnywayElement.Parameter {
    
    var valueForRegex: String {
        
        guard let value = field.value else { return "" }
        
        switch uiAttributes.dataType {
        case .number:
            return value.convertedToSBER(
                serviceDecimalSeparator: ".",
                serviceThousandSeparator: ","
            ) ?? ""
            
        default:
            return value
        }
    }
}

extension String {
    
    func convertedToSBER(
        from locale: Locale = .autoupdatingCurrent,
        serviceDecimalSeparator: String,
        serviceThousandSeparator: String
    ) -> String? {
        
        let decimal = NumberFormatter.decimal(for: locale)
        let sber = NumberFormatter.sberDecimal
        
        guard let number = decimal.number(from: self),
              let sberFormatted = sber.string(from: number)
        else { return nil }
        
        return sberFormatted
    }
}

extension NumberFormatter {
    
    static func decimal(
        for locale: Locale
    ) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        
        return formatter
    }
    
    static var sberDecimal: NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        
        return formatter
    }
}
