//
//  ReactiveFetchingUpdater+ext.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public extension ReactiveFetchingUpdater {
    
    convenience init<Item>(
        fetch: @escaping Fetch,
        map: @escaping (T) -> [Item],
        update: AnyPublisher<Dictionary<Item.Key, Item.Value>, Never>
    ) where V == [Item], Item: KeyProviding, Item: ValueUpdatable {
        
        self.init(
            fetch: fetch,
            update: { return map($0).updating(with: update) }
        )
    }
}
