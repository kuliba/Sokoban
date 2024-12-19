//
//  Array+updating.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

/// Extends `Array` where its elements provide a unique key and can be updated with a new value.
///
/// This extension offers a mechanism to reactively apply dictionary-based updates to the array elements over time.
public extension Array
where Element: KeyProviding,
      Element: ValueUpdatable {
    
    /// Returns a publisher that emits updated arrays of elements whenever the provided `update` publisher emits new values.
    ///
    /// - Parameter update: A publisher emitting dictionaries that map each element's `key` to a new `value`.
    /// - Returns: A publisher that first emits the current array, then emits a new array for each update,
    ///   applying any changes from the dictionary to elements with matching keys.
    func updating(
        with update: AnyPublisher<Dictionary<Element.Key, Element.Value>, Never>
    ) -> AnyPublisher<Self, Never> {
        
        guard !isEmpty else { return Just([]).eraseToAnyPublisher() }
        
        return update
            .scan(self) { currentItems, updates in
                
                currentItems.map { item in
                    
                    if let newValue = updates[item.key] {
                        return item.updated(value: newValue)
                    } else {
                        return item
                    }
                }
            }
            .prepend(self)
            .eraseToAnyPublisher()
    }
}
