//
//  XCTestCase+fetch.swift
//  
//
//  Created by Igor Malyarov on 09.11.2023.
//

import Fetcher
import XCTest

extension XCTestCase {
    
    func fetch<Payload, Success: Equatable, Failure: Error>(
        _ sut: any Fetcher<Payload, Success, Failure>,
        _ payload: Payload,
        on action: @escaping () -> Void
    ) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(payload) { _ in exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func fetch<Success: Equatable, Failure: Error>(
        _ sut: any Fetcher<Request, Success, Failure>,
        on action: @escaping () -> Void
    ) {
        fetch(sut, anyRequest(), on: action)
    }
}
