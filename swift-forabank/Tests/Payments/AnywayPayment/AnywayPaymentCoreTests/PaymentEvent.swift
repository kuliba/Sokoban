//
//  PaymentEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

enum PaymentEvent<Update> {
    
    case update(Result<Update, ServiceFailure>)
}

extension PaymentEvent: Equatable where Update: Equatable {}
