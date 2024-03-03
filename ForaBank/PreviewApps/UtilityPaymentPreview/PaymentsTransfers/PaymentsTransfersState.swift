//
//  PaymentsTransfersState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

struct PaymentsTransfersState: Equatable {
    
    var prePayment: Result<PrePaymentState, ServiceFailure>?
    var status: Status?
    
    enum Status: Equatable {
        
        case inflight
    }
}
