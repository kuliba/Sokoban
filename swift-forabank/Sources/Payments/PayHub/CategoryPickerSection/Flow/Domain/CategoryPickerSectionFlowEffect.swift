//
//  CategoryPickerSectionFlowEffect.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum CategoryPickerSectionFlowEffect<Category> {
    
    case showAll([Category])
    case showCategory(Category)
}

extension CategoryPickerSectionFlowEffect: Equatable where Category: Equatable {}
