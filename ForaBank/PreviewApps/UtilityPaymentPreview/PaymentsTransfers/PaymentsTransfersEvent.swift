//
//  PaymentsTransfersEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

enum PaymentsTransfersEvent: Equatable {
    
    case back
    case openUtilityPayment
    case utilityFlow(UtilityFlowEvent)
}

extension PaymentsTransfersEvent {
    
    struct StartPayment: Equatable {}
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, PaymentsTransfersEvent.StartPayment, UtilityService>
}
