//
//  CategoryPickerSectionFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias CategoryPickerSectionFlowWrapperView<ContentView, Category, SelectedCategory, CategoryList> = RxWrapperView<ContentView, CategoryPickerSectionFlowState<SelectedCategory, CategoryList>, CategoryPickerSectionFlowEvent<Category, SelectedCategory, CategoryList>, CategoryPickerSectionFlowEffect<Category>> where ContentView: View
