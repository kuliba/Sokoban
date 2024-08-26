//
//  CategoryPickerSectionFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias CategoryPickerSectionFlowWrapperView<ContentView, Category, CategoryModel, CategoryList> = RxWrapperView<ContentView, CategoryPickerSectionFlowState<CategoryModel, CategoryList>, CategoryPickerSectionFlowEvent<Category, CategoryModel, CategoryList>, CategoryPickerSectionFlowEffect<Category>> where ContentView: View
