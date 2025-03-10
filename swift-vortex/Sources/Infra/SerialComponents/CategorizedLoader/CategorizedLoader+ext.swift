//
//  CategorizedLoader+ext.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

public extension CategorizedLoader {
    
    /// A function type that loads items for a category, optionally using a serial value.
    typealias StampedLoad<Payload, Serial, T> = (Payload, Serial?, @escaping (Result<SerialComponents.SerialStamped<Serial, T>, Error>) -> Void) -> Void
    
    /// Convenience initializer that assembles the loader using the given behaviors.
    ///
    /// - Parameters:
    ///   - initialStorage: The optional starting storage of categorized data.
    ///   - loadCategories: The function to fetch the list of categories.
    ///   - loadItems: The function to load items for a given category.
    convenience init(
        initialStorage: CategorizedStorage<Category, Item>?,
        loadCategories: @escaping Load<[Category]?>,
        loadItems: @escaping StampedLoad<Category, String, [Item]>
    ) {
        let store = Store(value: initialStorage)
        let decorator = Decorator(
            initialStorage: initialStorage,
            loadItems: loadItems,
            update: { stamped, completion in
                
                store.update(with: stamped) { _ in completion() }
            }
        )
        let batcher = Batcher { category, completion in
            
            decorator.decorated(category) { completion($0.failure) }
        }
        
        self.init(
            batcher: batcher,
            decorator: decorator,
            loadCategories: loadCategories,
            store: store
        )
    }
}

private extension Result {
    
    /// Returns the error if the result represents a failure; otherwise, returns nil.
    var failure: Failure? {
        
        guard case let .failure(failure) = self else { return nil }
        
        return failure
    }
}
