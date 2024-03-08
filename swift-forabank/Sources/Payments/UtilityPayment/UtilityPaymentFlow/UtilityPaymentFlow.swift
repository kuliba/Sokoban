//
//  UtilityPaymentFlow.swift
//
//
//  Created by Igor Malyarov on 08.03.2024.
//

import PrePaymentPicker

public enum UtilityPaymentFlow<LastPayment, Operator> {
    
    case prePaymentOptions(PrePaymentOptions)
    case prePaymentState(PrePaymentState)
}

public extension UtilityPaymentFlow {
    
    typealias PrePaymentOptions = PrePaymentOptionsState<LastPayment, Operator>
}

extension UtilityPaymentFlow: Equatable where LastPayment: Equatable, Operator: Equatable {}
