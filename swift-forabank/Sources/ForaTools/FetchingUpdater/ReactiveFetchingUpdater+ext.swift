//
//  ReactiveFetchingUpdater+ext.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public extension ReactiveFetchingUpdater {
    
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
