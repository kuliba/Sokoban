//
//  PaymentsTransfersEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

enum PaymentsTransfersEvent: Equatable {
    
    case openUtilityPayment
    case utilityPayment(UtilityFlowEvent)
    
    #warning("remove cases!!!!!!!!")
    
    #warning("move to `UtilityPaymentEvent`")
    case openPrePayment
    #warning("rename to loadPrePayment")
    case loaded(Result<PrePayment, SimpleServiceFailure>)
    case loadedServices(LoadServicesResponse, for: Operator)
    case payByInstruction
#warning("move to `UtilityPaymentEvent`")
    case prePayment(PPEvent)
    case resetDestination
#warning("move to `UtilityPaymentEvent`")
    case startPaymentResponse(StartPaymentResponse)
}

extension PaymentsTransfersEvent {
    
    struct PrePayment: Equatable {}
    
    typealias StartPaymentResponse = Result<StartPayment, ServiceFailure>
    
    struct StartPayment: Equatable {}
    
    enum LoadServicesResponse: Equatable {
        
        case failure
        case list([UtilityService]) // non-empty!
        case single(UtilityService)
    }
    
    typealias PPEvent = PrePaymentEvent<LastPayment, Operator, PaymentsTransfersEvent.LoadServicesResponse, UtilityService>
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, PaymentsTransfersEvent.StartPayment, UtilityService>
}
