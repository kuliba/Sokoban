//
//  Spy.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

final class Spy<Payload, Response> {
    
    private(set) var messages = [Message]()
}

extension Spy {
    
    var callCount: Int { messages.count }
    var payloads: [Payload] { messages.map(\.payload) }
    
    func process(
        _ payload: Payload,
        completion: @escaping Completion
    ) {
        messages.append((payload, completion))
    }
    
    func complete(
        with response: Response,
        at index: Int = 0
    ) {
        messages[index].completion(response)
    }
}

extension Spy {
    
    typealias Completion = (Response) -> Void
    typealias Message = (payload: Payload, completion: Completion)
}

extension Spy where Payload == Void {
    
    func process(completion: @escaping Completion) {
        
        process((), completion: completion)
    }
}
