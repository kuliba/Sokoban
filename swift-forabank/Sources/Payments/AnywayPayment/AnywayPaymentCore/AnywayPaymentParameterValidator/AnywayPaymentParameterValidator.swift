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
    
    func isValid(_ parameter: Parameter) -> Bool {
        
        guard isRequiredValid(parameter),
              isMinLengthValid(parameter),
              isMaxLengthValid(parameter),
              isRegExpValid(parameter)
        else { return false }
        
        return true
    }
}

public extension AnywayPaymentParameterValidator {
    
    typealias Parameter = AnywayElement.Parameter
}

private extension AnywayPaymentParameterValidator {
    
    func isRequiredValid(_ parameter: Parameter) -> Bool {
        
        parameter.validation.isRequired
        ? parameter.field.value != nil
        : true
    }
    
    func isMinLengthValid(_ parameter: Parameter) -> Bool {
        
        guard let minLength = parameter.validation.minLength else { return true }
        
        let value = parameter.field.value ?? ""
        
        return value.count >= minLength
    }
    
    func isMaxLengthValid(_ parameter: Parameter) -> Bool {
        
        guard let maxLength = parameter.validation.maxLength else { return true }
        
        let value = parameter.field.value ?? ""
        
        return value.count <= maxLength
    }
    
    func isRegExpValid(_ parameter: Parameter) -> Bool {
        
        guard !parameter.validation.regExp.isEmpty else { return true }
        
        let value = parameter.field.value ?? ""
        let pattern = parameter.validation.regExp
        
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}
