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
public enum CategoryPickerContentDomain<Category>
where Category: Identifiable {}

public extension CategoryPickerContentDomain {
    
    typealias ItemListDomain = PayHub.ItemListDomain<UUID, Category>
        
    typealias State = ItemListDomain.State
    typealias Event = ItemListDomain.Event
    typealias Effect = ItemListDomain.Effect
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    typealias Reducer = LoadablePickerReducer<UUID, Category>
    typealias EffectHandler = LoadablePickerEffectHandler<Category>
}
