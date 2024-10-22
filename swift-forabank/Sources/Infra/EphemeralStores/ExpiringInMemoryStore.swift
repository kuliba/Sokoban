//
//  ExpiringInMemoryStore.swift
//
//
//  Created by Igor Malyarov on 12.10.2024.
//

import GenericLoader

public final class ExpiringInMemoryStore<T> {
    
    private let store: InMemoryStore<Cached<T>>
    
    public init(store: InMemoryStore<Cached<T>> = .init()) {
        
        self.store = store
    }
    
    public func insert(_ cached: Cached<T>) async {
        
        await self.store.insert(cached)
    }
    
    public func retrieve() async -> Cached<T>? {
        
        await self.store.retrieve()
    }
    
    public func delete() async {
        
        await self.store.delete()
    }
}
