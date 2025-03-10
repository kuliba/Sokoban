//
//  MonolithicStore+update.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

public extension MonolithicStore {
    
    /// Merges a new categorized storage with the existing store data.
    ///
    /// This method updates the store as follows:
    /// - If the store is empty, it inserts the new storage.
    /// - If the store already contains a value, it merges that value with the new storage.
    ///   - When the merge results in changes, it inserts the merged storage.
    ///   - When no changes occur, it completes successfully without a new insert.
    /// - If the store instance is deallocated before retrieval completes, the update is aborted.
    ///
    /// - Parameters:
    ///   - storage: The new categorized storage to merge into the store.
    ///   - completion: A closure that is called with the insertion result.
    @inlinable
    func update<T, V>(
        with storage: CategorizedStorage<T, V>,
        completion: @escaping (Result<Void, Error>) -> Void
    ) where Value == CategorizedStorage<T, V>, Self: AnyObject {
        
        retrieve { [weak self] value in
            
            guard let self else { return }
            
            guard let value
            else { return insert(storage, completion) }
            
            let (merged, isUpdated) = value.merged(with: storage)
            
            if isUpdated {
                insert(merged, completion)
            } else {
                completion(.success(()))
            }
        }
    }
}
