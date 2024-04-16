//
//  AnywayPaymentEvent.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import AnywayPaymentCore
import Foundation

enum AnywayPaymentEvent: Equatable {
    
    case amount(Decimal)
    case otp(String)
    #warning("this is demo only, `pay` is a higher, i.e. transaction, level event")
    case pay
    case setValue(String, for: ParameterID)
}

extension AnywayPaymentEvent {
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
}
