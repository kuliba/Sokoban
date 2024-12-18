//
//  ValueUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

/// A publisher-driven value updater that listens to updates and produces a stream of modified items.
///
/// `ValueUpdater` observes a stream of dictionary updates. Each update associates keys (matching the keys of the items)
/// to new values. Upon receiving an update, it produces a new array of items where items with matching keys are replaced by updated copies.
/// Non-matching keys are ignored, leaving the corresponding items unchanged.
///
/// The `updatingItems` publisher first emits the initial array of items (if any), and then for each subsequent update,
/// it emits a new array reflecting any changed values.
public final class ValueUpdater<T, Key, Value>
where Key: Hashable,
      T: KeyProviding<Key>,
      T: ValueUpdatable<Value> {
    
    private let items: [T]
    private let update: AnyPublisher<Dictionary<Key, Value>, Never>
    
    /// Creates a `ValueUpdater` with an initial array of items and an update publisher.
    ///
    /// - Parameters:
    ///   - items: The initial list of items to be managed and potentially updated.
    ///   - update: A publisher emitting dictionaries of updates, mapping keys to new values.
    public init(
        items: [T],
        update: AnyPublisher<Dictionary<Key, Value>, Never>
    ) {
        self.items = items
        self.update = update
    }
}

extension ValueUpdater {
    
    /// A publisher that first emits the initial items, then emits updated arrays whenever `update` publishes changes.
    ///
    /// - If `items` is empty, it immediately emits an empty array and no further updates are emitted.
    /// - Otherwise, it prepends the initial items and then, for each dictionary of updates:
    ///   - For each item in the current array, if the item's key matches a key in the update dictionary,
    ///     a new updated item is produced with the updated value.
    ///   - If there's no matching key, the item remains unchanged.
    /// This process results in a new array of items which is emitted downstream.
    public var updatingItems: AnyPublisher<[T], Never> {
        
        guard !items.isEmpty
        else { return Just([]).eraseToAnyPublisher() }
        
        return update
            .scan(items) { currentItems, updates in
                currentItems.map { item in
                    if let newValue = updates[item.key] {
                        return item.updated(value: newValue)
                    } else {
                        return item
                    }
                }
            }
            .prepend(items)
            .eraseToAnyPublisher()
    }
}
