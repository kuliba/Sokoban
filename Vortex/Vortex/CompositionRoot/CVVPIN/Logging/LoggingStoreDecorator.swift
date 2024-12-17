//
//  LoggingStoreDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import GenericLoader
import Foundation

final class LoggingStoreDecorator<T> {
    
    typealias Log = (LoggerAgentLevel, String, StaticString, UInt) -> Void
    
    let decoratee: any Store<T>
    let log: Log
    
    init(
        decoratee: any Store<T>,
        log: @escaping Log
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingStoreDecorator: GenericLoader.Store {
    
    typealias Local = T
    
    func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        decoratee.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log(.error, "Store \(String(describing: self)): Retrieval failure: \(error).", #file, #line)
                
            case let .success((model, validUntil)):
                log(.info, "Store \(String(describing: self)): Retrieval success: \(model) valid until \(validUntil).", #file, #line)
            }
            completion(result)
        }
    }
    
    func insert(
        _ local: T,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    ) {
        decoratee.insert(local, validUntil: validUntil) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log(.error, "Store \(String(describing: self)): Insertion failure: \(local) validUntil \(validUntil): \(error).", #file, #line)
                
            case .success:
                log(.info, "Store \(String(describing: self)): Insertion success: \(local) validUntil \(validUntil).", #file, #line)
            }
            completion(result)
        }
    }
    
    func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        decoratee.deleteCache { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log(.error, "Store \(String(describing: self)): Cache deletion failure: \(error).", #file, #line)
            case .success:
                log(.info, "Store \(String(describing: self)): Cache deletion success.", #file, #line)
            }
            completion(result)
        }
    }
}
