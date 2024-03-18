//
//  PaymentsTransfersEvent.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 17.03.2024.
//

import UtilityPayment

enum PaymentsTransfersEvent: Equatable {
    
    case flow(FlowEvent)
    case tap(TapEvent)
}

extension PaymentsTransfersEvent {
    
    typealias FlowEvent = PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService, StartPayment>
    
    enum TapEvent: Equatable {
        
        case addCompany
        case goToMain
    }
}
