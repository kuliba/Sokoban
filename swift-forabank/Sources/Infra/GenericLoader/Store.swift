//
//  Store.swift
//  
//
//  Created by Igor Malyarov on 06.10.2023.
//

import Foundation

public typealias Cached<T> = (T, validUntil: Date)

public protocol Store<Local> {
    
    associatedtype Local
    
    // MARK: - retrieve
    
    typealias RetrievalResult = Result<Cached<Local>, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func retrieve(completion: @escaping RetrievalCompletion)
    
    // MARK:  - insert
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func insert(
        _ local: Local,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    )
    
    // MARK:  - delete
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    func deleteCache(completion: @escaping DeletionCompletion)
}
