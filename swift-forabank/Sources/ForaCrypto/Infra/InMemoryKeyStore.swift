//
//  InMemoryKeyStore.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import Foundation

public final class InMemoryKeyStore<Key> {
    
    private var key: Key?
    private let queue = DispatchQueue(label: "\(InMemoryKeyStore.self)Queue", attributes: .concurrent)
    
    public init() {}
    
    public func saveKey(
        _ keyToSave: Key,
        completion: @escaping KeyCacheDomain<Key>.Completion
    ) {
        queue.async(flags: .barrier) { [weak self] in
            
            guard let self else { return }
            
            key = keyToSave
            completion(.success(()))
        }
    }
    
    #warning("what `payload: Void` is for????")
    public func loadKey(
        _ payload: Void,
        completion: @escaping KeyLoadDomain<Void, Key>.Completion
    ) {
        // https://forums.swift.org/t/deadlock-issue-when-accessing-thread-safe-objects-within-task-withtaskgroup/65322/3
        queue.async {
            
            completion(.init { [weak self] in
                
                guard let self, let key else {
                    throw NSError(domain: "", code: 0)
                }
                
                return key
            })
        }
    }
}
