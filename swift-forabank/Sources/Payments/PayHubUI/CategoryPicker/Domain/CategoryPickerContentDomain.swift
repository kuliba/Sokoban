//
//  CategoryPickerContentDomain.swift
//  
//
//  Created by Igor Malyarov on 08.10.2024.
//

import Foundation
import PayHub
import RxViewModel

/// A namespace.
public enum CategoryPickerContentDomain<Category, List> {}

public extension CategoryPickerContentDomain {
    
    typealias Item = CategoryPickerItem<Category, List>
    
    typealias State = LoadablePickerState<UUID, Item>
    typealias Event = LoadablePickerEvent<Item>
    typealias Effect = LoadablePickerEffect
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    typealias Reducer = LoadablePickerReducer<UUID, Item>
    typealias EffectHandler = LoadablePickerEffectHandler<Item>
}
