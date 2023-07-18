//
//  CodableSessionCodeStore.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import Foundation

public final class CodableSessionCodeStore: SessionCodeStore {
    
    private let storeURL: URL
    private let queue = DispatchQueue(
        label: "\(CodableSessionCodeStore.self)Queue",
        attributes: .concurrent
    )
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
}

// MARK: - retrieve

extension CodableSessionCodeStore {
    
    public func retrieve(
        completion: @escaping RetrievalCompletion
    ) {
        let storeURL = storeURL
        
        queue.async {
            
            completion(.init {
                let data = try Data(contentsOf: storeURL)
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                return (cache.codableSessionCode.local, cache.timestamp)
            }.mapError { _ in Error.retrieveFailure })
        }
    }
    
    public enum Error: Swift.Error {
        
        case retrieveFailure
    }
}

// MARK: - insert

extension CodableSessionCodeStore {
    
    public func insert(
        _ localSessionCode: LocalSessionCode,
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        let storeURL = storeURL
        
        queue.async(flags: .barrier) {
            
            completion(.init {
                let encoder = JSONEncoder()
                let data = try encoder.encode(Cache(codableSessionCode: .init(local: localSessionCode), timestamp: timestamp))
                try data.write(to: storeURL)
            })
        }
    }
}

// MARK: - deleteCachedSessionCode

extension CodableSessionCodeStore {
    
    public func deleteCachedSessionCode(
        completion: @escaping DeletionCompletion
    ) {
        let fileManager = FileManager.default
        let storeURL = storeURL
        
        queue.async(flags: .barrier) {
            
            guard fileManager.fileExists(atPath: storeURL.path)
            else { return completion(.success(())) }
            
            completion(.init {
                try fileManager.removeItem(at: storeURL)
            })
        }
    }
}

extension CodableSessionCodeStore {
    
    private struct Cache: Codable {
        
        let codableSessionCode: CodableSessionCode
        let timestamp: Date
    }
    
    private struct CodableSessionCode: Equatable, Codable {
        
        let value: String
        
        init(local: LocalSessionCode) {
            
            self.value = local.value
        }
        
        var local: LocalSessionCode {
            
            .init(value: value)
        }
    }
}
