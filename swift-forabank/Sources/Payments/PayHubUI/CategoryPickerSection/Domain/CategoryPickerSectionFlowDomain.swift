//
//  CategoryPickerSectionFlowDomain.swift
//  
//
//  Created by Igor Malyarov on 28.09.2024.
//

import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPickerSectionFlowDomain<Category, Navigation> {}

public extension CategoryPickerSectionFlowDomain {
    
    typealias Select = CategoryPickerSectionItem<Category, [Category]>
    
    typealias FlowState = CategoryPickerSectionFlowState<Navigation>
    typealias FlowEvent = CategoryPickerSectionFlowEvent<Select, Navigation>
    typealias FlowEffect = CategoryPickerSectionFlowEffect<Select>
    
    typealias Flow = RxViewModel<FlowState, FlowEvent, FlowEffect>
    
    typealias FlowReducer = CategoryPickerSectionFlowReducer<Select, Navigation>
    typealias FlowEffectHandler = CategoryPickerSectionFlowEffectHandler<Select, Navigation>
    typealias MicroServices = CategoryPickerSectionFlowEffectHandlerMicroServices<Select, Navigation>
}
