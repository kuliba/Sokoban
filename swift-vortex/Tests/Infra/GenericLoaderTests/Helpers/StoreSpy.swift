//
//  StoreSpy.swift
//  
//
//  Created by Igor Malyarov on 11.10.2023.
//

import GenericLoader
import Foundation

final class StoreSpy<T>: Store {
    
    typealias Local = T
    
    private(set) var messages = [Message]()
    var callCount: Int { messages.count }
    
    // MARK: - retrieve
    
    private(set) var retrievalCompletions = [RetrievalCompletion]()
    
    func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        messages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(
        with error: Error,
        at index: Int = 0
    ) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(
        with cache: Cached<T>,
        at index: Int = 0
    ) {
        retrievalCompletions[index](.success(cache))
    }
    
    func completeRetrievalWithEmptyCache(
        at index: Int = 0
    ) {
        completeRetrieval(with: anyError("Empty Cache Error"), at: index)
    }
    
    // MARK: - insert
    
    private(set) var insertionCompletions = [InsertionCompletion]()
    
    func insert(
        _ local: T,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    ) {
        messages.append(.insert(local, validUntil))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(
        with error: Error,
        at index: Int = 0
    ) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(
        at index: Int = 0
    ) {
        insertionCompletions[index](.success(()))
    }
    
    // MARK: - delete cache
    
    private(set) var deletionCompletions = [DeletionCompletion]()
    
    func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        messages.append(.delete)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(
        with error: Error,
        at index: Int = 0
    ) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(
        at index: Int = 0
    ) {
        deletionCompletions[index](.success(()))
    }
    
    // MARK: - Message
    
    enum Message {
        
        case retrieve
        case insert(T, Date)
        case delete
    }
}

extension StoreSpy.Message: Equatable where T: Equatable {}
