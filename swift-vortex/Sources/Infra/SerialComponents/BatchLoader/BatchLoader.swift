//
//  BatchLoader.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import EphemeralStores
import VortexTools

public final class BatchLoader<Payload, Response>
where Payload: Hashable {
    
    @usableFromInline
    let batcher: Batcher
    @usableFromInline
    let store: Store

    public init(
        batcher: Batcher,
        store: Store
    ) {
        self.batcher = batcher
        self.store = store
    }
    
    public typealias Batcher = VortexTools.Batcher<Payload>
    public typealias Store = EphemeralStores.InMemoryStore<[Payload: Response]>
}

public extension BatchLoader {
    
    @inlinable
    func load(
        payloads: [Payload],
        completion: @escaping (Outcome<Payload, Response>) -> Void
    ) {
        batcher.process(payloads) { [weak self] failed in
            
            self?.store.retrieve { storage in
                
                completion(.init(storage: storage ?? [:], failed: failed))
            }
        }
    }
}
