//
//  PaymentsTransfersState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

struct PaymentsTransfersState: Equatable {
    
    var destination: Destination?
}

extension PaymentsTransfersState {
    
    enum Destination: Equatable {
        
        case utilityFlow(UtilityFlow)
    }
    
    typealias UtilityFlow = UtilityPaymentFlowState<LastPayment, Operator, UtilityService>
}
