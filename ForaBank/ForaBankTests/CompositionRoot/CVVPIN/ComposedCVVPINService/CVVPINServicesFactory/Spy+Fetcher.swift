//
//  Spy+Fetcher.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.11.2023.
//

import Fetcher

typealias FetcherSpy<Payload, Success, Failure: Error> = Spy<Payload, Success, Failure>

extension Spy: Fetcher {
    
    typealias FetchCompletion = Completion
    
    func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    ) {
        process(payload, completion: completion)
    }
}
