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
public enum CategoryPickerContentDomain<Category> {}

public extension CategoryPickerContentDomain {
        
    typealias State = LoadablePickerState<UUID, Category>
    typealias Event = LoadablePickerEvent<Category>
    typealias Effect = LoadablePickerEffect
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    typealias Reducer = LoadablePickerReducer<UUID, Category>
    typealias EffectHandler = LoadablePickerEffectHandler<Category>
}
