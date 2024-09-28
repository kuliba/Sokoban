//
//  CategoryPickerSectionFlowDomain.swift
//  
//
//  Created by Igor Malyarov on 28.09.2024.
//

import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPickerSectionFlowDomain<Category, SelectedCategory, CategoryList, Failure: Error> {}

public extension CategoryPickerSectionFlowDomain {
    
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
