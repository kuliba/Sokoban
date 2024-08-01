//
//  RemoveDuplicatesDecorator.swift
//
//
//  Created by Igor Malyarov on 19.03.2024.
//

import Foundation

/// A decorator class to prevent duplicate function calls with the same payload.
public final class RemoveDuplicatesDecorator<Payload, Response>
where Payload: Equatable {
    
    private var lastPayload: Payload?
    private let queue = DispatchQueue(label: "com.RemoveDuplicatesDecorator.queue")
    
    public init() {}
}

public extension RemoveDuplicatesDecorator {
    
    /// Returns a function that prevents execution if the payload is a duplicate.
    /// Uses a weak reference to self to prevent retain cycles.
    /// - Parameter f: The function to be wrapped.
    /// - Returns: A new function that checks for duplicate payloads.
    func removeDuplicates(_ f: @escaping F) -> F {
        
        return { [weak self] payload, completion in
            
            self?.queue.sync {
                
                self?.execute(payload: payload, f: f, completion: completion)
            }
        }
    }
    
    /// Returns a function that prevents execution if the payload is a duplicate.
    /// Uses a strong reference to self.
    /// - Parameter f: The function to be wrapped.
    /// - Returns: A new function that checks for duplicate payloads.
    func callAsFunction(_ f: @escaping F) -> F {
        
        return { payload, completion in
            
            self.queue.sync {
                
                self.execute(payload: payload, f: f, completion: completion)
            }
        }
    }
}

public extension RemoveDuplicatesDecorator {
    
    typealias Completion = (Response) -> Void
    typealias F = (Payload, @escaping Completion) -> Void
}

private extension RemoveDuplicatesDecorator {
    
    func execute(
        payload: Payload,
        f: @escaping F,
        completion: @escaping Completion
    ) {
        guard payload != lastPayload else { return }
        
        lastPayload = payload
        f(payload, completion)
    }
}
