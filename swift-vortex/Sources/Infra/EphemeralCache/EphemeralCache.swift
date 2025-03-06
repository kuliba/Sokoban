//
//  EphemeralCache.swift
//
//
//  Created by Igor Malyarov on 06.03.2025.
//

import Foundation

/// A thread-safe cache that holds weak references to model objects.
///
/// Behavior:
///   - Models are stored as weak references so they can be deallocated if not retained elsewhere.
///   - When retrieving an object, the cache returns the model if it exists or removes the stale entry if it has been deallocated.
///
/// Important:
///   - Clients should implement a cache cleaning strategy (e.g., periodic or threshold-based cleanup) to manage memory effectively.
public final class EphemeralCache<Key: Hashable, Model: AnyObject> {
    
    private var _cache: [Key: WeakBox<Model>] = [:]
    private let lock = NSRecursiveLock()
    
    public init(
        cache: [Key : WeakBox<Model>] = [:]
    ) {
        self._cache = cache
    }
}

public extension EphemeralCache {
    
    /// Retrieves the model associated with the given key.
    ///
    /// Behavior:
    ///   - Returns the model if it is available.
    ///   - If the model has been deallocated, cleans up the stale entry by removing it from the cache.
    ///
    /// Parameter key: The key to look up in the cache.
    ///
    /// Returns: The model for the given key, or `nil` if not found or deallocated.
    func object(forKey key: Key) -> Model? {
        
        lock.lock()
        defer { lock.unlock() }
        
        let model = _cache[key]?.model
        _cache[key] = model.map { .init(model: $0) }
        
        return model
    }
    
    /// Caches the model for the given key.
    ///
    /// Behavior:
    ///   - Stores the model wrapped in a weak reference, ensuring that it can be deallocated if there are no strong references elsewhere.
    ///
    /// Parameter model: The model to cache.
    /// Parameter key: The key associated with the model.
    func cache(_ model: Model, forKey key: Key) {
        
        lock.lock()
        defer { lock.unlock() }
        
        _cache[key] = WeakBox(model: model)
    }
    
    /// Removes stale entries from the cache.
    ///
    /// Behavior:
    ///   - Iterates over the cache and removes any entry where the model has been deallocated.
    ///
    /// Note:
    ///   - This method is part of the cache maintenance process. Clients should integrate this cleanup into a broader cache cleaning strategy (e.g., periodic cleanup, memory warning handling).
    func cleanup() {
        
        lock.lock()
        defer { lock.unlock() }
        
        _cache = _cache.filter { $0.value.model != nil }
    }
}

public extension EphemeralCache {
    
    /// Provides subscript support for accessing and modifying cache entries.
    /// Retrieves or sets the model associated with the given key.
    ///
    /// Behavior:
    ///   - Getting the value uses `object(forKey:)`, returning the model if available.
    ///   - Setting a new value uses a functional approach to wrap the model in a weak reference;
    ///     assigning `nil` removes the entry.
    subscript(key: Key) -> Model? {
        
        get { return object(forKey: key) }
        
        set {
            lock.lock()
            defer { lock.unlock() }
            
            _cache[key] = newValue.map { .init(model: $0) }
        }
    }
}
