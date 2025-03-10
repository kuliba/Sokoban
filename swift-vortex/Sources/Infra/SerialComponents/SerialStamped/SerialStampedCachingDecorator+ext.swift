//
//  SerialStampedCachingDecorator+ext.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

public extension SerialStampedCachingDecorator {
    
    /// A function type that loads items for a given payload and optional serial, calling a completion with a stamped result or an error.
    ///
    /// - Parameters:
    ///   - payload: The payload (e.g., category) to load items for.
    ///   - serial: The last known serial (if any) for this payload.
    ///   - completion: A completion closure receiving a `Result` with the stamped items or an `Error`.
    typealias StampedLoad<T> = (Payload, Serial?, @escaping (Result<SerialComponents.SerialStamped<Serial, T>, Error>) -> Void) -> Void
    
    /// A function type that updates a categorized storage with new items, then calls a completion.
    ///
    /// - Parameters:
    ///   - storage: The new storage state holding items and their serial.
    ///   - completion: A completion closure to call after updating.
    typealias CategorizedUpdate<Item> = (CategorizedStorage<Payload, Item>,@escaping () -> Void) -> Void where Payload: Hashable, Item: Categorized<Payload>
    
    /// A convenience initializer that configures a `SerialStampedCachingDecorator` to work with categorized storage.
    ///
    /// This initializer uses `initialStorage` to retrieve a last-known serial for a given payload, then calls `loadItems`
    /// with that serial. Upon a successful load, it creates a new `CategorizedStorage` and updates it via `update`.
    ///
    /// - Parameters:
    ///   - initialStorage: An optional initial storage containing items and a serial stamp. If `serial(for:)` matches
    ///                     the payload, it will be passed to `loadItems` for conditional fetching.
    ///   - loadItems: A function to load items given a payload and an optional serial, returning a stamped result or an error.
    ///   - update: A function to update categorized storage with newly fetched items (and their serial).
    convenience init<Item>(
        initialStorage: CategorizedStorage<Payload, Item>?,
        loadItems: @escaping StampedLoad<[Item]>,
        update: @escaping CategorizedUpdate<Item>
    ) where Item: Categorized<Payload>, Payload: Hashable, Serial == String, Value == [Item] {
        
        self.init(
            decoratee: { category, completion in
                
                let serial = initialStorage?.serial(for: category)
                loadItems(category, serial, completion)
            },
            cache: { stamped, completion in
                
                let storage = CategorizedStorage(items: stamped.value, serial: stamped.serial)
                update(storage, completion)
            }
        )
    }
}
