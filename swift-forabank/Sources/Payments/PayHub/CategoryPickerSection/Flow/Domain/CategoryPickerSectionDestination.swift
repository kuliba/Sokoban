//
//  CategoryPickerSectionDestination.swift
//  
//
//  Created by Igor Malyarov on 26.08.2024.
//

public enum CategoryPickerSectionDestination<SelectedCategory, CategoryList> {
    
    case category(SelectedCategory)
    case list(CategoryList)
}

extension CategoryPickerSectionDestination: Equatable where SelectedCategory: Equatable, CategoryList: Equatable {}
