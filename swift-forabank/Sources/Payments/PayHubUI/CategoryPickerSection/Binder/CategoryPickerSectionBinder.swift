//
//  CategoryPickerSectionBinder.swift
//  
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub

public typealias CategoryPickerSectionBinder<Category, CategoryModel, CategoryList> = Binder<CategoryPickerSectionContent<Category>, CategoryPickerSectionFlow<Category, CategoryModel, CategoryList>>
