//
//  UtilityPaymentDestination.swift
//
//
//  Created by Igor Malyarov on 08.03.2024.
//

import PrePaymentPicker

@available(*, deprecated, message: "use `UtilityDestination`")
public enum UtilityPaymentDestination<LastPayment, Operator, Service> {
    
    case prePaymentOptions(PrePaymentOptions)
    case prePaymentState(PrePayment)
    case payment
}

public extension UtilityPaymentDestination {
    
    typealias PrePaymentOptions = PrePaymentOptionsState<LastPayment, Operator>
    typealias PrePayment = PrePaymentState<LastPayment, Operator, Service>
}

extension UtilityPaymentDestination: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
