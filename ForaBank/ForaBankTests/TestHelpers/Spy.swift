//
//  Spy.swift
//
//
//  Created by Igor Malyarov on 12.11.2023.
//

final class Spy<Payload, Success, Failure: Error> {
    
    typealias Result = Swift.Result<Success, Failure>
    typealias Completion = (Result) -> Void
    typealias Message = (payload: Payload, completion: Completion)
    
    private(set) var messages = [Message]()
    
    var callCount: Int { messages.count }
    var payloads: [Payload] { messages.map(\.payload) }
    
    func process(
        _ payload: Payload,
        completion: @escaping Completion
    ) {
        messages.append((payload, completion))
    }
    
    func complete(
        with result: Result,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
}

extension Spy where Payload == Void {
    
    func process(completion: @escaping Completion) {
        
        process((), completion: completion)
    }
}

extension Spy where Failure == Never {
    
    func process(
        _ payload: Payload,
        completion: @escaping (Success) -> Void
    ) {
        process(payload) {
            switch $0 {
            case let .success(success):
                completion(success)
            }
        }
    }
    
    func complete(with success: Success, at index: Int = 0) {
        
        complete(with: .success(success), at: index)
    }
}

extension Spy where Payload == Void, Failure == Never {
    
    func process(
        completion: @escaping (Success) -> Void
    ) {
        process(()) {
            switch $0 {
            case let .success(success):
                completion(success)
            }
        }
    }
    
    func complete(with success: Success, at index: Int = 0) {
        
        complete(with: .success(success), at: index)
    }
}
