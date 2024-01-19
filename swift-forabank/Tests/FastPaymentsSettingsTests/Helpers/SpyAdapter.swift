//
//  SpyAdapter.swift
//  
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings

final class SpyAdapter<Payload, Output, ProcessError: Error>: RemoteServiceInterface {
    
    private let spy: Spy<Payload, Result<Output, ProcessError>>

    init(spy: Spy<Payload, Result<Output, ProcessError>>) {
        
        self.spy = spy
    }

    func process(
        _ input: Payload,
        completion: @escaping (Result<Output, ProcessError>) -> Void
    ) {
        spy.process(input, completion: completion)
    }
}
