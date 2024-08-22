//
//  CategoryPickerSectionContent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation
import PayHub
import RxViewModel

enum CategoryPickerSectionItem: Equatable {
    
    case category(ServiceCategory)
    case showAll
}

typealias CategoryPickerSectionState = LoadablePickerState<UUID, CategoryPickerSectionItem>
typealias CategoryPickerSectionEvent = LoadablePickerEvent<CategoryPickerSectionItem>
typealias CategoryPickerSectionEffect = LoadablePickerEffect

typealias CategoryPickerSectionReducer = LoadablePickerReducer<UUID, CategoryPickerSectionItem>
typealias CategoryPickerSectionEffectHandler = LoadablePickerEffectHandler<CategoryPickerSectionItem>

typealias CategoryPickerSectionContent = RxViewModel<CategoryPickerSectionState, CategoryPickerSectionEvent, CategoryPickerSectionEffect>
