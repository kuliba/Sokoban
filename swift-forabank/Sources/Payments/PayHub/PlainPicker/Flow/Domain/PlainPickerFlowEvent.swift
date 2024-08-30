//
//  PlainPickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public enum PlainPickerFlowEvent<Element, Navigation> {
    
    case dismiss
    case navigation(Navigation)
    case select(Element)
}

extension PlainPickerFlowEvent: Equatable where Element: Equatable, Navigation: Equatable {}
