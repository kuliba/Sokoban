//
//  KeyCacheDomain.swift
//  
//
//  Created by Igor Malyarov on 17.08.2023.
//

public enum KeyCacheDomain<Key> {}

public extension KeyCacheDomain {
    
    typealias Result = Swift.Result<Void, Error>
    typealias Completion = (Result) -> Void
    typealias SaveKey = (Key, @escaping Completion) -> Void
}
