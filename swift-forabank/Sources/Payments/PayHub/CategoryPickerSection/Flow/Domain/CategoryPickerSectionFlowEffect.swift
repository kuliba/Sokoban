//
//  CategoryPickerSectionFlowEffect.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum CategoryPickerSectionFlowEffect<Select> {
    
    case select(Select)
}

extension CategoryPickerSectionFlowEffect: Equatable where Select: Equatable {}
