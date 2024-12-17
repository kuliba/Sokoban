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
        
        let error = validator.validate(context.payment)
        
        // TODO: add tests
        guard let error else { return nil }
        
        switch (context.shouldRestart, error) {
            // TODO: a better way would be to collect all - not just first - validation errors and check that it contains `footerValidationError`
        case (true, .footerValidationError):
            return nil
            
        case (true, .otpValidationError):
            return nil
            
        default:
            return error
        }
    }
}
