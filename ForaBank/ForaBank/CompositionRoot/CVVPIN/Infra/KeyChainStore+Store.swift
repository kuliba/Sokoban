//
//  KeyChainStore+Store.swift
//  Vortex
//
//  Created by Igor Malyarov on 14.10.2023.
//

import GenericLoader
import Foundation
import KeyChainStore

extension KeyChainStore: GenericLoader.Store {
    
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
