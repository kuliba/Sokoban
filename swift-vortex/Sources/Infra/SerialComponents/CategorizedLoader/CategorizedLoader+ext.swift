//
//  CategorizedLoader+ext.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

public extension CategorizedLoader {
    
    typealias StampedLoad<Payload, Serial, T> = (Payload, Serial?, @escaping (Result<SerialComponents.SerialStamped<Serial, T>, Error>) -> Void) -> Void
    
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
    
    var failure: Failure? {
        
        guard case let .failure(failure) = self else { return nil }
        
        return failure
    }
}
