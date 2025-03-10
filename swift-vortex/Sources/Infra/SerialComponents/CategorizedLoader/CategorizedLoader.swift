//
//  CategorizedLoader.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import EphemeralStores
import VortexTools

/// Loads categorized items by fetching categories and then loading items for each category,
/// applying caching behavior and reporting any categories that failed to load.
public final class CategorizedLoader<Category, Item>
where Category: Hashable,
      Item: Categorized<Category> {
    
    /// Batcher for processing categories.
    @usableFromInline
    let batcher: Batcher
    /// Caching decorator that wraps the loadItems function.
    @usableFromInline
    let decorator: Decorator
    /// Closure to load an array of categories.
    @usableFromInline
    let loadCategories: Load<[Category]?>
    /// In-memory store used to cache categorized storage.
    @usableFromInline
    let store: Store
    
    /// Initializes the loader with pre-configured collaborators.
    ///
    /// - Parameters:
    ///   - batcher: Coordinates the loading of items for each category.
    ///   - decorator: Wraps the item loading with caching behavior.
    ///   - loadCategories: Fetches the list of categories.
    ///   - store: Caches the categorized data.
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
    
    /// Type alias for the batcher, specialized to the Category type.
    public typealias Batcher = VortexTools.Batcher<Category>
    /// Type alias for the caching decorator with serial stamping.
    public typealias Decorator = SerialStampedCachingDecorator<Category, String, [Item]>
    /// Type alias for the in-memory store holding the categorized storage.
    public typealias Store = EphemeralStores.InMemoryStore<CategorizedStorage<Category, Item>>
}

public extension CategorizedLoader {
    
    /// Initiates the load operation by:
    /// 1. Fetching categories.
    /// 2. Loading items for each category with caching.
    /// 3. Returning the cached storage along with a list of any categories that failed.
    ///
    /// - Parameter completion: Called with the final outcome of the load operation.
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
