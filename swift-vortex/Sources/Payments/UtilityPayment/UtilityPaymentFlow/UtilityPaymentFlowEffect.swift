//
//  UtilityPaymentFlowEffect.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

@available(*, deprecated, message: "use `UtilityFlowEffect`")
public enum UtilityPaymentFlowEffect<LastPayment, Operator, Service>
where Operator: Identifiable {
    
    case prePaymentOptions(PrePaymentOptions)
    case prePayment(PrePayment)
}

public extension UtilityPaymentFlowEffect {
    
    typealias PrePaymentOptions = PrePaymentOptionsEffect<Operator>
    typealias PrePayment = PrePaymentEffect<LastPayment, Operator, Service>
}

extension UtilityPaymentFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
