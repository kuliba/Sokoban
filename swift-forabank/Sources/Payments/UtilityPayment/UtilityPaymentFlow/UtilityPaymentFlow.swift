//
//  UtilityPaymentFlow.swift
//
//
//  Created by Igor Malyarov on 08.03.2024.
//

import PrePaymentPicker

public enum UtilityPaymentFlow<LastPayment, Operator, Service> {
    
    case prePaymentOptions(PrePaymentOptions)
    case prePaymentState(PrePayment)
    case payment
}

public extension UtilityPaymentFlow {
    
    typealias PrePaymentOptions = PrePaymentOptionsState<LastPayment, Operator>
    typealias PrePayment = PrePaymentState<LastPayment, Operator, Service>
}

extension UtilityPaymentFlow: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
