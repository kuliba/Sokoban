//
//  PickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public enum PickerFlowEvent<Element, Navigation> {
    
    case dismiss
    case navigation(Navigation)
    case select(Element)
}

extension PickerFlowEvent: Equatable where Element: Equatable, Navigation: Equatable {}
