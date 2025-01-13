//
//  ReactiveFetchingUpdater+ext.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public extension ReactiveFetchingUpdater {
    
    /// A convenience initializer that maps fetched `T` into `[Item]` and applies updates from a dictionary publisher.
    ///
    /// - Parameters:
    ///   - fetcher: The optional fetcher providing the initial `T`.
    ///   - map: A closure mapping `T` to `[Item]`.
    ///   - update: A publisher of dictionaries mapping each `Item`'s key to an updated value.
    ///
    /// Conforms `V` to `[Item]` where `Item` is `KeyProviding` and `ValueUpdatable`.
    convenience init<Item>(
        fetcher: any Fetcher,
        map: @escaping (T) -> [Item],
        update: AnyPublisher<Dictionary<Item.Key, Item.Value>, Never>
    ) where V == [Item], Item: KeyProviding, Item: ValueUpdatable {
        
        self.init(
            fetcher: fetcher,
            updater: AnyReactiveUpdater { map($0).updating(with: update) }
        )
    }
}
