//
//  PaymentsTransfersState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

struct PaymentsTransfersState: Equatable {
    
    var route: Route?
    var status: Status?
}

extension PaymentsTransfersState {
    
    enum Route: Equatable {
        
        case utilityPayment(UtilityPayment)
    }
    
    enum Status: Equatable {
        
        case inflight
    }
    
    typealias UtilityPayment = UtilityPaymentFlowState<LastPayment, Operator>
}
