//
//  UtilityPaymentFlowEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

@available(*, deprecated, message: "use `UtilityFlowEvent`")
public enum UtilityPaymentFlowEvent<LastPayment, Operator, Response, Service>
where Operator: Identifiable {
    
    case back
    case prePaymentOptions(PrePaymentOptions)
    case prePayment(PrePayment)
}

public extension UtilityPaymentFlowEvent {
    
    typealias PrePaymentOptions = PrePaymentOptionsEvent<LastPayment, Operator>
    typealias PrePayment = PrePaymentEvent<LastPayment, Operator, Response, Service>
}

extension UtilityPaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Response: Equatable, Service: Equatable {}
