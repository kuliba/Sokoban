//
//  Spy.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

final class Spy<Payload, Response> {
    
    typealias Completion = (Response) -> Void
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
        with response: Response,
        at index: Int = 0
    ) {
        messages[index].completion(response)
    }
}

extension Spy where Payload == Void {
    
    func process(completion: @escaping Completion) {
        
        process((), completion: completion)
    }
}
