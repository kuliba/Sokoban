//
//  CategoryPickerSectionFlowEvent.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum CategoryPickerSectionFlowEvent<Select, Navigation> {
    
    case dismiss
    case receive(Navigation)
    case select(Select)
}

extension CategoryPickerSectionFlowEvent: Equatable where Select: Equatable, Navigation: Equatable {}
