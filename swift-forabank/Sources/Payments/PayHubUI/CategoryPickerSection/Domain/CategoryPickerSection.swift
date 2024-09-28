//
//  CategoryPickerSection.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import Foundation
import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPickerSection<Category, SelectedCategory, CategoryList, Failure: Error> {}

public extension CategoryPickerSection {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<CategoryPickerSectionContentDomain<Category>.Content, Flow>
    typealias BinderComposer = CategoryPickerSectionBinderComposer<Category, SelectedCategory, CategoryList, Failure>
    
    // MARK: - Flow
    
    typealias Select = CategoryPickerSectionItem<Category, [Category]>
    
    typealias FlowState = CategoryPickerSectionFlowState<Navigation>
    typealias FlowEvent = CategoryPickerSectionFlowEvent<Select, Navigation>
    typealias FlowEffect = CategoryPickerSectionFlowEffect<Select>
    
    typealias Flow = RxViewModel<FlowState, FlowEvent, FlowEffect>
    
    typealias FlowReducer = CategoryPickerSectionFlowReducer<Select, Navigation>
    typealias FlowEffectHandler = CategoryPickerSectionFlowEffectHandler<Select, Navigation>
    typealias MicroServices = CategoryPickerSectionFlowEffectHandlerMicroServices<Select, Navigation>
    
    typealias Navigation = CategoryPickerNavigation<Destination, Failure>
    typealias Destination = CategoryPickerSectionItem<SelectedCategory, CategoryList>
}

public enum CategoryPickerNavigation<Destination, Failure> {
    
    case destination(Destination)
    case failure(Failure)
}

extension CategoryPickerNavigation: Equatable where Destination: Equatable, Failure: Equatable {}
