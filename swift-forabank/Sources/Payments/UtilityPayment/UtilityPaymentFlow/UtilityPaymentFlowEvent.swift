//
//  UtilityPaymentFlowEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

public enum UtilityPaymentFlowEvent<LastPayment, Operator>
where Operator: Identifiable {
    
    case prePaymentOptions(PrePaymentOptions)
    case prePayment(PrePaymentEvent)
}

public extension UtilityPaymentFlowEvent {
    
    typealias PrePaymentOptions = PrePaymentOptionsEvent<LastPayment, Operator>
}

extension UtilityPaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
