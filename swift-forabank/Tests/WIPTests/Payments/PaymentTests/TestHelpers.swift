//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 22.03.2024.
//

import Foundation

func makePayment(
    _ parameter: PaymentParameter.Parameter,
    _ parameters: PaymentParameter.Parameter...
) -> Payment {
    
    .init(
        parameters: ([parameter] + parameters)
            .map { .init(parameter: $0, isValid: true) }
    )
}

func makePayment(
    _ parameters: (PaymentParameter.Parameter, Bool)...
) -> Payment {
    
    .init(parameters: parameters.map {
        .init(parameter: $0.0, isValid: $0.1)
    })
}

func inputEvent(
    _ value: String = UUID().uuidString
) -> PaymentParameterEvent {
    
    .input(.edit(value))
}

func selectEvent(
) -> PaymentParameterEvent {
    
    .select(.toggleChevron)
}

func makePaymentParameter(
    _ parameter: PaymentParameter.Parameter,
    isValid: Bool = true
) -> PaymentParameter {
    
    .init(parameter: parameter, isValid: isValid)
}

func makeInputParameter(
    value: String = UUID().uuidString
) -> InputParameter {
    
    .init(value: value)
}

func makeSelectParameter(
    id: String = UUID().uuidString
) -> SelectParameter {
    
    .init(id: id)
}
