//
//  AnywayPaymentContextValidator.swift
//
//
//  Created by Igor Malyarov on 23.06.2024.
//

import AnywayPaymentDomain

public final class AnywayPaymentContextValidator {
    
    public init() {}
    
    public func validate(
        _ context: AnywayPaymentContext
    ) -> AnywayPaymentValidationError? {
        
        let parameterValidator = AnywayPaymentParameterValidator()
        let validator = AnywayPaymentValidator(
            validateParameter: parameterValidator.validate
        )
        
        return validator.validate(context.payment)
    }
}
