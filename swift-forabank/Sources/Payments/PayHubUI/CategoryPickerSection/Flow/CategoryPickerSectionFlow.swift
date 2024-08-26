//
//  CategoryPickerSectionFlow.swift
//  
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import RxViewModel

public typealias CategoryPickerSectionFlow<Category, CategoryModel, CategoryList> = RxViewModel<CategoryPickerSectionFlowState<CategoryModel, CategoryList>, CategoryPickerSectionFlowEvent<Category, CategoryModel, CategoryList>, CategoryPickerSectionFlowEffect<Category>>
