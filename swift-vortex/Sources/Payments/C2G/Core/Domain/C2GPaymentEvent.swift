//
//  C2GPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import PaymentComponents

public enum C2GPaymentEvent: Equatable {
    
    case productSelect(ProductSelectEvent)
    case termsToggle
}
