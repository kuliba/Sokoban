//
//  CategoryPickerSectionFlow.swift
//  
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import RxViewModel

public typealias CategoryPickerSectionFlow<Category, SelectedCategory, CategoryList> = RxViewModel<CategoryPickerSectionFlowState<SelectedCategory, CategoryList>, CategoryPickerSectionFlowEvent<Category, SelectedCategory, CategoryList>, CategoryPickerSectionFlowEffect<Category>>
