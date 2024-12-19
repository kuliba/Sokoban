//
//  LoggingStoreDecorator.swift
//  
//
//  Created by Igor Malyarov on 07.10.2023.
//

import Foundation
import GenericLoader

public final class LoggingStoreDecorator<T> {
    
    public typealias Log = (String) -> Void
    
    private let decoratee: any Store<T>
    private let log: Log
    
    public init(
        decoratee: any Store<T>,
        log: @escaping Log
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingStoreDecorator: Store {
    
    public typealias Local = T

    public func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        log("Retrieve requested.")
        
        decoratee.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log("Retrieval failure: \(error).")
                completion(.failure(error))
                
            case let .success((local, validUntil)):
                log("Retrieval success with \(local) valid until \(validUntil).")
                completion(.success((local, validUntil)))
            }
        }
    }
    
    public func insert(
        _ local: Local,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    ) {
        log("Requested insert of \(local) valid until \(validUntil).")
        
        decoratee.insert(
            local,
            validUntil: validUntil
        ) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log("Insertion failure: \(error).")
                completion(.failure(error))
                
            case .success:
                log("Insertion success with \(local) valid until \(validUntil).")
                completion(.success(()))
            }
        }
    }
    
    public func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        log("Requested cache deletion.")
        
        decoratee.deleteCache { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log("Cache deletion failure: \(error).")
                completion(.failure(error))
                
            case .success:
                log("Cache deletion success.")
                completion(.success(()))
            }
        }
    }
}
