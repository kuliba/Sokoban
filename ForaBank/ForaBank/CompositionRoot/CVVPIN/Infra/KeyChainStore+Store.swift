//
//  KeyChainStore+Store.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.10.2023.
//

import CVVPINServices
import Foundation
import KeyChainStore

extension KeyChainStore: Store {
    
    public typealias Local = Key
    
    public func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        completion(.init { try load() })
    }
    
    public func insert(
        _ local: Key,
        validUntil: Date,
        completion: @escaping InsertionCompletion
    ) {
        completion(.init { try save((local, validUntil)) })
    }
    
    public func deleteCache(
        completion: @escaping DeletionCompletion
    ) {
        completion(.init { clear() })
    }
    
    enum Error: Swift.Error {
        
        case copyPublicKeyFailure
    }
}
