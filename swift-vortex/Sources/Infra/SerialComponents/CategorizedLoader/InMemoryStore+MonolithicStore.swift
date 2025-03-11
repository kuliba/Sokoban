//
//  InMemoryStore+MonolithicStore.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import EphemeralStores

extension EphemeralStores.InMemoryStore: MonolithicStore {
    
    nonisolated public func insert(
        _ value: Value,
        _ completion : @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            
            await self.insert(value)
            completion(.success(()))
        }
    }
    
    nonisolated public func retrieve(
        _ completion : @escaping (Value?) -> Void
    ) {
        Task {
            
            let cache = await self.retrieve()
            completion(cache)
        }
    }
}
