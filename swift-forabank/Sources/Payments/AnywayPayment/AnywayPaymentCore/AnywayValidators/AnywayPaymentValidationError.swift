//
//  AnywayPaymentValidationError.swift
//  
//
//  Created by Igor Malyarov on 23.06.2024.
//

import AnywayPaymentDomain

public enum AnywayPaymentValidationError: Equatable {
    
    case footerValidationError
    case parameterValidationErrors(Errors)
    
    public typealias Errors = [ID: AnywayPaymentParameterValidationError]
    public typealias ID = AnywayElement.Parameter.Field.ID
}
