//
//  CachedModelsState.swift
//
//
//  Created by Igor Malyarov on 04.06.2024.
//

import Foundation

/// A state management structure that maintains a cache of models identified by keys.
///
/// This struct is used to manage a collection of models where each model is associated with a unique key.
/// It provides functionality to initialise the state with key-model pairs, update the state with new items,
/// and manage the cache efficiently by evicting unused models.
public struct CachedModelsState<Key: Hashable, Model> {
    
    private var keys: [Key]
    private var cache: [Key: Model]
    
    private init(
        keys: [Key],
        cache: [Key : Model]
    ) {
        self.keys = keys
        self.cache = cache
    }
    
    /// Initialises a new instance from an array of key-model pairs.
    /// - Parameter pairs: An array of tuples where each tuple contains a key and a model.
    public init(pairs: [(Key, Model)]) {
        
        self.init(
            keys: pairs.map(\.0),
            cache: .init(uniqueKeysWithValues: pairs)
        )
    }
}

extension CachedModelsState: Equatable where Model: Equatable {}

internal extension CachedModelsState {
    
    /// The number of models in the cache.
    var cacheCount: Int { cache.count }
}

public extension CachedModelsState {
    
    /// An array of models corresponding to the keys.
    var models: [Model] { keys.compactMap { cache[$0] }}
    
    /// An array of key-model pairs.
    var keyModelPairs: [(Key, Model)] {
    
        keys.compactMap { key in cache[key].map { (key, $0) }}
    }
    
    /// Updates the state with an array of identifiable items, using a given function to create models.
    ///
    /// - Parameters:
    ///   - items: An array of items to update the state with.
    ///   - makeModel: A function that creates a model from an item.
    /// - Returns: A new `CachedModelsState` instance with the updated items.
    func updating<Item>(
        with items: [Item],
        using makeModel: @escaping (Item) -> Model
    ) -> Self where Item: Identifiable, Key == Item.ID {
        
        let items = items.uniqueValues()
        let keys = items.map(\.id)
        
        var cache = updateCache(with: items, using: makeModel)
        cache = evictUnusedModels(from: cache, keys: keys)
        
        return .init(keys: keys, cache: cache)
    }
}

private extension CachedModelsState {
    
    /// Updates the cache with new items, adding new models if needed.
    /// - Parameters:
    ///   - items: An array of items to update the cache with.
    ///   - makeModel: A function that creates a model from an item.
    /// - Returns: An updated cache dictionary.
    func updateCache<Item>(
        with items: [Item],
        using makeModel: @escaping (Item) -> Model
    ) -> [Key: Model] where Item: Identifiable, Key == Item.ID {
        
        var updatedCache = cache
        for item in items where updatedCache[item.id] == nil {
            updatedCache[item.id] = makeModel(item)
        }
        
        return updatedCache
    }
    
    /// Evicts unused models from the cache.
    /// - Parameters:
    ///   - cache: The cache dictionary to update.
    ///   - keys: The keys to retain in the cache.
    /// - Returns: An updated cache dictionary with unused models removed.
    func evictUnusedModels(
        from cache: [Key: Model],
        keys: [Key]
    ) -> [Key: Model] {
        
        var updatedCache = cache
        let existingKeys = Set(keys)
        
        for key in updatedCache.keys where !existingKeys.contains(key) {
            updatedCache[key] = nil
        }
        
        return updatedCache
    }
}
