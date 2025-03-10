//
//  CategorizedOutcome.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

/// Represents the result of a categorized load operation, including the final cached storage
/// and any categories that encountered failures.
public struct CategorizedOutcome<Category, Item>
where Category: Hashable,
      Item: Categorized<Category> {
    
    /// The cached storage after loading.
    public let storage: Storage
    /// Categories that failed to load items.
    public let failed: [Category]
    
    /// Initializes the outcome with cached storage and any failed categories.
    ///
    /// - Parameters:
    ///   - storage: The final categorized storage.
    ///   - failed: The list of categories that could not be loaded.
    public init(
        storage: Storage,
        failed: [Category]
    ) {
        self.storage = storage
        self.failed = failed
    }
    
    public typealias Storage = CategorizedStorage<Category, Item>?
}

extension CategorizedOutcome: Equatable where Item: Equatable{}
