//
//  LoadableResourceViewModel+init.swift
//  
//
//  Created by Igor Malyarov on 24.06.2023.
//

import Combine

public extension LoadableResourceViewModel {
    
    convenience init(
        operation: @escaping () async throws -> Resource,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            publisher: AnyPublisher(operation),
            scheduler: scheduler
        )
    }
}

public extension AnyPublisher where Failure == Error {
    
    init(_ operation: @escaping () async throws -> Output) {
        
        self = Deferred {
            
            Future(operation)
        }
        .eraseToAnyPublisher()
    }
}

private extension Future where Failure == Error {
    
    convenience init(
        _ operation: @escaping () async throws -> Output
    ) {
        self.init { completion in
            
            Task {
                
                do {
                    let output = try await operation()
                    completion(.success(output))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
