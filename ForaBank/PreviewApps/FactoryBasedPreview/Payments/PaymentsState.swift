//
//  PaymentsState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

struct PaymentsState {
    
    var destination: Destination?
}

extension PaymentsState {
    
    enum Destination {
        
        case utilityServicePayment
    }
}
