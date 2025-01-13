//
//  LocalSessionCodeLoader.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import Foundation

public final class LocalSessionCodeLoader {
    
    private let store: SessionCodeStore
    private let currentDate: () -> Date
    private let isExpired: (Date) -> Bool
    
    public init(
        store: SessionCodeStore,
        currentDate: @escaping () -> Date,
        isExpired: @escaping (Date) -> Bool
    ) {
        self.store = store
        self.currentDate = currentDate
        self.isExpired = isExpired
    }
}

// MARK: - save

extension LocalSessionCodeLoader {
    
    public typealias SaveResult = Swift.Result<Void, Error>
    public typealias SaveCompletion = (SaveResult) -> Void
    public typealias SessionCode = GetProcessingSessionCodeDomain.SessionCode
    
    public func save(
        _ sessionCode: SessionCode,
        completion: @escaping SaveCompletion
    ) {
        store.deleteCachedSessionCode { [weak self] deletionResult in
            
            guard let self else { return }
            
            switch deletionResult {
            case let .failure(error):
                completion(.failure(error))
                
            case .success:
                cache(sessionCode, with: completion)
            }
        }
    }
    
    private func cache(
        _ sessionCode: SessionCode,
        with completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(sessionCode.local, timestamp: currentDate()) { [weak self] insertionResult in
            
            guard self != nil else { return }
            
            switch insertionResult {
            case let .failure(error):
                completion(.failure(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

// MARK: - load

extension LocalSessionCodeLoader: SessionCodeLoader {
    
    public typealias Result = Swift.Result<SessionCode, LoadError>
    
    public func load(completion: @escaping LoadCompletion) {
        
        self.store.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(LoadError.loadFailure))
                
            case let .success((localSessionCode, timestamp)) where !self.isExpired(timestamp):
                completion(.success(localSessionCode.toModel))
                
            case .success:
                completion(.failure(LoadError.expiredCache))
            }
        }
    }
    
    public enum LoadError: Error {
        
        case expiredCache
        case loadFailure
    }
}

// MARK: - validateCache

extension LocalSessionCodeLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                store.deleteCachedSessionCode { _ in }
                
            case let .success((_, timestamp)) where self.isExpired(timestamp):
                store.deleteCachedSessionCode { _ in }
                
            case .success:
                break
            }
        }
    }
}

private extension GetProcessingSessionCodeDomain.SessionCode {
    
    var local: LocalSessionCode {
        
        .init(value: value)
    }
}

private extension LocalSessionCode {
    
    var toModel: GetProcessingSessionCodeDomain.SessionCode {
        
        .init(value: value)
    }
}
