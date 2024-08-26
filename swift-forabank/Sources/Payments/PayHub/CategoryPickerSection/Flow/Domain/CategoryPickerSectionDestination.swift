//
//  CategoryPickerSectionDestination.swift
//  
//
//  Created by Igor Malyarov on 26.08.2024.
//

public enum CategoryPickerSectionDestination<CategoryModel, CategoryList> {
    
    case category(CategoryModel)
    case list(CategoryList)
}

extension CategoryPickerSectionDestination: Equatable where CategoryModel: Equatable, CategoryList: Equatable {}
