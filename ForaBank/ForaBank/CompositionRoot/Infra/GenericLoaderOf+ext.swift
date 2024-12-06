//
//  GenericLoaderOf+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.08.2024.
//

import EphemeralStores
import Foundation

extension GenericLoaderOf
where Local == Model {
    
    convenience init() {
        
        self.init(store: ExpiringInMemoryStore<Model>())
    }
    
    // ignore errors
    func load<T>(
        _ completion: @escaping ([T]) -> Void
    ) where Model == [T] {
        
        self.load { completion((try? $0.get()) ?? []) }
    }
    
    // ignore errors and empty
    func save<T>(
        _ values: Model,
        _ completion: @escaping () -> Void
    ) where Model == [T] {
        
        guard !values.isEmpty else { return completion() }
        
        self.save(values, validUntil: .distantFuture) { _ in
            
            completion()
        }
    }
}
