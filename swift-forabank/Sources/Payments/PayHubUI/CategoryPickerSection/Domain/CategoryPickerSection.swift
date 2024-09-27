//
//  CategoryPickerSection.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPickerSection<Category, SelectedCategory, CategoryList, Failure: Error> {}

public extension CategoryPickerSection {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<CategoryPickerSectionContent<Category>, Flow>
    typealias BinderComposer = CategoryPickerSectionBinderComposer<Category, SelectedCategory, CategoryList, Failure>
    
    // MARK: - Content
    
#warning("move content here")
    typealias Content = CategoryPickerSectionContent<Category>
    
    // MARK: - Flow
    
    typealias FlowState = CategoryPickerSectionFlowState<SelectedCategory, CategoryList, Failure>
    typealias FlowEvent = CategoryPickerSectionFlowEvent<Category, SelectedCategory, CategoryList, Failure>
    typealias FlowEffect = CategoryPickerSectionFlowEffect<Category>
    
    typealias Flow = RxViewModel<FlowState, FlowEvent, FlowEffect>
    
    typealias FlowReducer = CategoryPickerSectionFlowReducer<Category, SelectedCategory, CategoryList, Failure>
    typealias FlowEffectHandler = CategoryPickerSectionFlowEffectHandler<Category, SelectedCategory, CategoryList, Failure>
    typealias MicroServices = CategoryPickerSectionFlowEffectHandlerMicroServices<Category, SelectedCategory, CategoryList, Failure>
}
