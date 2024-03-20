//
//  RemoveDuplicatesDecorator.swift
//
//
//  Created by Igor Malyarov on 19.03.2024.
//

import Foundation

public final class RemoveDuplicatesDecorator<Payload, Response>
where Payload: Equatable {
    
    private var lastPayload: Payload?
    private let queue = DispatchQueue(label: "com.RemoveDuplicatesDecorator.queue")
    
    public init() {}
}

public extension RemoveDuplicatesDecorator {
    
    func callAsFunction(_ f: @escaping F) -> F {
        
        return { [weak self] payload, completion in
            
            self?.queue.sync {
                
                guard payload != self?.lastPayload else { return }
                
                self?.lastPayload = payload
                f(payload, completion)
            }
        }
    }
}

public extension RemoveDuplicatesDecorator {
    
    typealias Completion = (Response) -> Void
    typealias F = (Payload, @escaping Completion) -> Void
}
