//
//  CircuitBreaker.swift
//  
//
//  Created by Igor Malyarov on 06.08.2023.
//

import Foundation

public final class CircuitBreaker<T> {
    
    public typealias ActionResult = Result<T, ErrorWithRetry>
    public typealias ActionCompletion = (ActionResult) -> Void
    public typealias Action = (@escaping ActionCompletion) -> Void
    
    public typealias CompletionResult = Result<T, Error>
    public typealias Completion = (CompletionResult) -> Void
    
    private let action: Action
    private let completion: Completion
    
    public init(
        action: @escaping Action,
        completion: @escaping Completion
    ) {
        self.action = action
        self.completion = completion
    }
    
    public func retry() {
        
        action { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(errorWithRetry):
                if errorWithRetry.canRetry {
                    retry()
                } else {
                    completion(.failure(errorWithRetry.error))
                }
                
            case let .success(success):
                completion(.success(success))
            }
        }
    }
    
    public struct ErrorWithRetry: Error {
        
        public let error: Error
        public let canRetry: Bool
        
        public init(
            error: Error,
            canRetry: Bool
        ) {
            self.error = error
            self.canRetry = canRetry
        }
    }
}
