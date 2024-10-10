//
//  CategoryPickerItem.swift
//  
//
//  Created by Igor Malyarov on 28.09.2024.
//

public enum CategoryPickerItem<Category, List> {
    
    case category(Category)
    case list(List)
}

extension CategoryPickerItem: Equatable where Category: Equatable, List: Equatable {}
