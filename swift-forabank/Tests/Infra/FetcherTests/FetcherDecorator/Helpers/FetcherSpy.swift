//
//  FetcherSpy.swift
//  
//
//  Created by Igor Malyarov on 09.11.2023.
//

import Fetcher

final class FetcherSpy<Request, Item, F: Error>: Fetcher {
    
    typealias Payload = Request
    typealias Success = Item
    typealias Failure = F
    
    typealias Message = (payload: Payload, completion: FetchCompletion)
    
    private var messages = [Message]()
    
    var callCount: Int { messages.count }
    var payloads: [Payload] { messages.map(\.payload) }
    
    func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    ) {
        messages.append((payload, completion))
    }
    
    func complete(
        with result: Result<Success, F>,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
}
