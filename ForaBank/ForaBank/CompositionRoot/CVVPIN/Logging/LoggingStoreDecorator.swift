//
//  LoggingStoreDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import CVVPINServices
import Foundation

final class LoggingStoreDecorator<T> {
    
    let decoratee: any Store<T>
    let log: (String, StaticString, UInt) -> Void
    
    init(
        decoratee: any Store<T>,
        log: @escaping (String, StaticString, UInt) -> Void
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingStoreDecorator: CVVPINServices.Store {
    
    typealias Local = T
    
    func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        decoratee.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log("Store \(String(describing: self)): Retrieval failure: \(error).", #file, #line)
                
            case let .success((model, validUntil)):
                log("Store \(String(describing: self)): Retrieval success: \(model), valid until \(validUntil).", #file, #line)
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
            
            log("Store \(String(describing: self)): Asked to insert \(local) validUntil \(validUntil). Insertion result: \(result).", #file, #line)
            completion(result)
        }
    }
    
    func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        decoratee.deleteCache { [weak self] result in
            
            guard let self else { return }
            
            log("Store \(String(describing: self)): Asked to delete cache. Deletion result: \(result).", #file, #line)
            completion(result)
        }
    }
}
