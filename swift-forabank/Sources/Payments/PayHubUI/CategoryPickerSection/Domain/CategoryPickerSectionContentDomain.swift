//
//  CategoryPickerSectionContentDomain.swift
//  
//
//  Created by Igor Malyarov on 28.09.2024.
//

import Foundation
import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPickerSectionContentDomain<Category> {}

public extension CategoryPickerSectionContentDomain {
    
    struct All: Equatable { public init() {} }
    typealias Item = CategoryPickerSectionItem<Category, All>
    
    typealias State = LoadablePickerState<UUID, Item>
    typealias Event = LoadablePickerEvent<Item>
    typealias Effect = LoadablePickerEffect
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    typealias Reducer = LoadablePickerReducer<UUID, Item>
    typealias EffectHandler = LoadablePickerEffectHandler<Item>
}
