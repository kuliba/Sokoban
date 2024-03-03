//
//  PaymentsTransfersState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

struct PaymentsTransfersState: Equatable {
    
    #warning("seems like enum case")
    var prePayment: Result<PrePaymentState, SimpleServiceFailure>?
    var status: Status?
    
    enum Status: Equatable {
        
        case inflight
    }
}
