//
//  CategorizedOutcome.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

public struct CategorizedOutcome<Category, Item>
where Category: Hashable,
      Item: Categorized<Category> {
    
    public let storage: Storage
    public let failed: [Category]
    
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
