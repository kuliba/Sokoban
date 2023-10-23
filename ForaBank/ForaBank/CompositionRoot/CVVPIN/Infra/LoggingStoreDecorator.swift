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
    let log: (String) -> Void
    
    init(
        decoratee: any Store<T>,
        log: @escaping (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .cache, message: $0) }
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingStoreDecorator: Store {
    
    typealias Local = T
    
    func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        decoratee.retrieve { [log] result in
            
            log("Store: Retrieval result: \(result).")
            completion(result)
        }
    }
    
    func insert(
        _ local: T,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    ) {
        decoratee.insert(local, validUntil: validUntil) { [log] result in
            
            log("Store: Asked to insert \(local) validUntil \(validUntil). Insertion result: \(result).")
            completion(result)
        }
    }
    
    func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        decoratee.deleteCache { [log] result in
            
            log("Store: Asked to delete cache. Deletion result: \(result).")
            completion(result)
        }
    }
}
