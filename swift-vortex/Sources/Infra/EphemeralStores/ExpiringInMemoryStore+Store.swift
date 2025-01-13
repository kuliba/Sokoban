//
//  ExpiringInMemoryStore+Store.swift
//
//
//  Created by Igor Malyarov on 12.10.2024.
//

import Foundation
import GenericLoader

extension ExpiringInMemoryStore: Store {
    
    public func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        Task {
            
            let cache = await self.retrieve()
            
            guard let cache else {
                
                return completion(.failure(RetrievalError()))
            }
            
            completion(.success(cache))
        }
    }
    
    struct RetrievalError: Error {}
    
    public func insert(
        _ local: T,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    ) {
        Task {
            
            await self.insert((local, validUntil))
            completion(.success(()))
        }
    }
    
    public func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        Task {
            
            await self.delete()
            completion(.success(()))
        }
    }
}
