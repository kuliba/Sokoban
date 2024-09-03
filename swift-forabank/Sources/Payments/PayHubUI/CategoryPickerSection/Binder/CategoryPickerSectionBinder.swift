//
//  CategoryPickerSectionBinder.swift
//  
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub

public typealias CategoryPickerSectionBinder<Category, SelectedCategory, CategoryList> = Binder<CategoryPickerSectionContent<Category>, CategoryPickerSectionFlow<Category, SelectedCategory, CategoryList>>
