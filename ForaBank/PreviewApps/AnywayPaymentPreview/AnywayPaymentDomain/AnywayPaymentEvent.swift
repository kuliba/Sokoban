//
//  AnywayPaymentEvent.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import AnywayPaymentCore

enum AnywayPaymentEvent: Equatable {
    
    case otp(String)
    case setValue(String, for: ParameterID)
}

extension AnywayPaymentEvent {
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
}
