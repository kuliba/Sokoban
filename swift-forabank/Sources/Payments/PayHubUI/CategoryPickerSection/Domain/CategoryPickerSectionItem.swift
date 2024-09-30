//
//  CategoryPickerSectionItem.swift
//  
//
//  Created by Igor Malyarov on 28.09.2024.
//

public enum CategoryPickerSectionItem<Category, CategoryList> {
    
    case category(Category)
    case list(CategoryList)
}

extension CategoryPickerSectionItem: Equatable where Category: Equatable, CategoryList: Equatable {}
