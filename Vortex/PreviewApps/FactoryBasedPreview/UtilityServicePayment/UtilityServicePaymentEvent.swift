//
//  UtilityServicePaymentEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

enum UtilityServicePaymentEvent: Equatable {
    
    case prepayment(UtilityServicePrepaymentEvent)
}
