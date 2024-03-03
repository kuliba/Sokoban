//
//  PaymentsTransfersEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

#warning("move to UtilityPaymentEffect")
enum PaymentsTransfersEffect: Equatable {
    
    case loadPrePayment
    case startPayment(StartPaymentPayload)
}

extension PaymentsTransfersEffect {
    
    enum StartPaymentPayload: Equatable {
        
        case last(LastPayment)
        case service(Operator, UtilityService)
    }
}
