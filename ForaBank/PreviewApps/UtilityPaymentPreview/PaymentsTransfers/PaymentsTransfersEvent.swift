//
//  PaymentsTransfersEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

enum PaymentsTransfersEvent: Equatable {
    
    #warning("move to `UtilityPaymentEvent`")
    case openPrePayment
    case loaded(Result<PrePayment, SimpleServiceFailure>)
    case payByInstruction
#warning("move to `UtilityPaymentEvent`")
    case prePayment(PrePaymentEvent)
    case resetDestination
#warning("move to `UtilityPaymentEvent`")
    case startPaymentResponse(StartPaymentResponse)
}

extension PaymentsTransfersEvent {
    
    struct PrePayment: Equatable {}
    
    typealias StartPaymentResponse = Result<StartPayment, ServiceFailure>
    
    struct StartPayment: Equatable {}
}
