//
//  AnywayMessage.swift
//  
//
//  Created by Igor Malyarov on 26.06.2024.
//

import AnywayPaymentCore

public enum AnywayMessage: Equatable {
    
    case otpWarning(String)
    case validation(AnywayPaymentValidationError)
}
