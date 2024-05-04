//
//  UtilityPaymentFlowEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import ForaTools

enum UtilityPaymentFlowEvent: Equatable {
    
    case prepayment(UtilityPrepaymentFlowEvent)
    case servicePicker(ServicePickerFlowEvent)
}

extension UtilityPaymentFlowEvent {
    
    enum UtilityPrepaymentFlowEvent: Equatable {
        
        case addCompany
        case dismissAlert
        case dismissDestination
        case dismissOperatorFailureDestination
        case dismissServicesDestination
        case payByInstructions
        case payByInstructionsFromError
        case paymentStarted(StartPaymentResult)
        case select(Select)
    }
    
    enum ServicePickerFlowEvent: Equatable {
        
        case dismissAlert
    }
}

extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
        case service(UtilityService, for: Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentSuccess, StartPaymentFailure>
    
    enum StartPaymentSuccess: Equatable {
        
        case services(MultiElementArray<UtilityService>, for: Operator)
        case startPayment(StartPaymentResponse)
        
        #warning("FIXME")
        struct StartPaymentResponse: Equatable {}
    }
    
    enum StartPaymentFailure: Error, Equatable {
        
        case operatorFailure(Operator)
        case serviceFailure(ServiceFailure)
    }
}
