//
//  InMemoryStore.swift
//  
//
//  Created by Igor Malyarov on 05.10.2023.
//

import Foundation

public final class InMemoryStore<Model> {
    
    private var cache: Cached<Model>?
    
    private let queue = DispatchQueue(
        label: "\(InMemoryStore.self)Queue",
        qos: .userInitiated
    //    attributes: .concurrent
    )
    
    public init(
        initialValue cache: Cached<Model>? = nil
    ) {
        self.cache = cache
    }
}

extension InMemoryStore: Store {
    
    public typealias Local = Model
    
    public func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        queue.async { [weak self] in
            
            guard let self else { return }
            
            completion(.init {
                
                try self.cache.get(orThrow: StoreError.emptyCache)
            })
        }
    }
    
    public func insert(
        _ local: Local,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    ) {
        queue.async(flags: .barrier) { [weak self] in
            
            guard let self else { return }
            
            self.cache = (local, validUntil)
            completion(.success(()))
        }
    }
    
    public func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        queue.async(flags: .barrier) { [weak self] in
            
            guard let self else { return }
            
            self.cache = nil
            completion(.success(()))
        }
    }
}

public extension InMemoryStore {
    
    enum StoreError: Error {
        
        case emptyCache
    }
}

extension Optional {
    
    func get(orThrow error: Error) throws -> Wrapped {
        
        guard let wrapped = self else { throw error }
        
        return wrapped
    }
}
