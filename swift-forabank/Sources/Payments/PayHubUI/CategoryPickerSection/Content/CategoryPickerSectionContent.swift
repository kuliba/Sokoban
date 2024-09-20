//
//  CategoryPickerSectionContent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import Foundation
import PayHub
import RxViewModel

public enum CategoryPickerSectionItem<ServiceCategory> {
    
    case category(ServiceCategory)
    case showAll
}

extension CategoryPickerSectionItem: Equatable where ServiceCategory: Equatable {}

public typealias CategoryPickerSectionState<ServiceCategory> = LoadablePickerState<UUID, CategoryPickerSectionItem<ServiceCategory>>
public typealias CategoryPickerSectionEvent<ServiceCategory> = LoadablePickerEvent<CategoryPickerSectionItem<ServiceCategory>>
public typealias CategoryPickerSectionEffect = LoadablePickerEffect

public typealias CategoryPickerSectionReducer<ServiceCategory> = LoadablePickerReducer<UUID, CategoryPickerSectionItem<ServiceCategory>>
public typealias CategoryPickerSectionEffectHandler<ServiceCategory> = LoadablePickerEffectHandler<CategoryPickerSectionItem<ServiceCategory>>

public typealias CategoryPickerSectionContent<ServiceCategory> = RxViewModel<CategoryPickerSectionState<ServiceCategory>, CategoryPickerSectionEvent<ServiceCategory>, CategoryPickerSectionEffect>
