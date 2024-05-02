//
//  PaymentsState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

struct PaymentsState: Equatable {
    
    var destination: Destination?
}

extension PaymentsState {
    
    typealias Destination = PaymentState
}
