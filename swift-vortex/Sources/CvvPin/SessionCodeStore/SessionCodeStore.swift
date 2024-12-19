//
//  SessionCodeStore.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import Foundation

public protocol SessionCodeStore {
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedSessionCode(
        completion: @escaping DeletionCompletion
    )
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(
        _ localSessionCode: LocalSessionCode,
        timestamp: Date,
        completion: @escaping InsertionCompletion
    )
    
    typealias CachedSessionCode = (LocalSessionCode, Date)
    typealias RetrievalResult = Result<CachedSessionCode, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(
        completion: @escaping RetrievalCompletion
    )
}
