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
        
        case prePayment(Result<PrePaymentState, SimpleServiceFailure>)
        case utilityPayment(UtilityPaymentState)
    }
    
    enum Status: Equatable {
        
        case inflight
    }
}
