//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 22.03.2024.
//

import Foundation

func inputEvent(
    _ value: String = UUID().uuidString
) -> PaymentParameterEvent {
    
    .input(.edit(value))
}

func selectEvent(
) -> PaymentParameterEvent {
    
    .select(.toggleChevron)
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
