//
//  ResponseSpy.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

final class ResponseSpy<Payload, Response> {

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

extension ResponseSpy where Payload == Void {
    
    func process(completion: @escaping Completion) {
        
        process((), completion: completion)
    }
}
