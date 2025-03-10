//
//  CategorizedLoader.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import EphemeralStores
import VortexTools

public final class CategorizedLoader<Category, Item>
where Category: Hashable,
      Item: Categorized<Category> {
    
    @usableFromInline
    let batcher: Batcher
    @usableFromInline
    let decorator: Decorator
    @usableFromInline
    let loadCategories: Load<[Category]?>
    @usableFromInline
    let store: Store
    
    public init(
        batcher: Batcher,
        decorator: Decorator,
        loadCategories: @escaping Load<[Category]?>,
        store: Store
    ) {
        self.batcher = batcher
        self.decorator = decorator
        self.loadCategories = loadCategories
        self.store = store
    }
    
    public typealias Batcher = VortexTools.Batcher<Category>
    public typealias Decorator = SerialStampedCachingDecorator<Category, String, [Item]>
    public typealias Store = EphemeralStores.InMemoryStore<CategorizedStorage<Category, Item>>
}

public extension CategorizedLoader {
    
    @inlinable
    func load(
        completion: @escaping (CategorizedOutcome<Category, Item>) -> Void
    ) {
        loadCategories { [weak self] result in
            
            self?.batcher.process(result ?? []) { [weak self] failed in
                
                self?.store.retrieve { storage in
                    
                    completion(.init(storage: storage, failed: failed))
                }
            }
        }
    }
}
