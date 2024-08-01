//
//  UtilityPaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain

enum UtilityPaymentFlowEvent<LastPayment, Operator, Service> {
    
    case payment(PaymentEvent)
    case prepayment(PrepaymentEvent)
    case servicePicker(ServicePickerFlowEvent)
}

extension UtilityPaymentFlowEvent {
    
    typealias PaymentEvent = UtilityServicePaymentFlowEvent
    typealias PrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    
    enum ServicePickerFlowEvent: Equatable {
        
        case dismissAlert
    }
}

extension UtilityPaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
