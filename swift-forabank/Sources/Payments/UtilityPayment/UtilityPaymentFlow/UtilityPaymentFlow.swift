//
//  UtilityPaymentFlow.swift
//
//
//  Created by Igor Malyarov on 08.03.2024.
//

import PrePaymentPicker

public enum UtilityPaymentFlow<LastPayment, Operator> {
    
    case prePaymentOptions(PrePaymentOptions)
    case prePaymentState(PrePayment)
}

public extension UtilityPaymentFlow {
    
    typealias PrePaymentOptions = PrePaymentOptionsState<LastPayment, Operator>
    typealias PrePayment = PrePaymentState<LastPayment, Operator>
}

extension UtilityPaymentFlow: Equatable where LastPayment: Equatable, Operator: Equatable {}
