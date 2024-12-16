//
//  AnywayPaymentParameterValidationError.swift
//  
//
//  Created by Igor Malyarov on 23.06.2024.
//

public enum AnywayPaymentParameterValidationError: Equatable {
    
    case emptyRequired
    case regExViolation
    case tooLong
    case tooShort
}
