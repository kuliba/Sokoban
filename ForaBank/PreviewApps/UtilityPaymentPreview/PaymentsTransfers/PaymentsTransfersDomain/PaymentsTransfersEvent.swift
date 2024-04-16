//
//  PaymentsTransfersEvent.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 17.03.2024.
//

import UtilityPayment

enum PaymentsTransfersEvent: Equatable {
    
    case flow(FlowEvent)
    // events that lead to changes of state that are out of `PaymentsTransfers` domain scope, like tab switching
    case alienScope(AlienScopeEvent)
}

extension PaymentsTransfersEvent {
    
    typealias FlowEvent = PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService, StartPayment>
    
    enum AlienScopeEvent: Equatable {
        
        case addCompany
        case goToMain
    }
}
