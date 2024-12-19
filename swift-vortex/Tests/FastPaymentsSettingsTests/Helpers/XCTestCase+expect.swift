//
//  XCTestCase+expect.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import RxViewModel
import XCTest

extension XCTestCase {
    
    func expect<Event, Effect>(
        _ sut: any EffectHandler<Event, Effect>,
        with effect: Effect,
        toDeliver expectedEvent: Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) where Event: Equatable, Effect: Equatable {
        
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) { receivedEvent in
            
            XCTAssertNoDiff(
                receivedEvent,
                expectedEvent,
                "\nExpected \(expectedEvent), but got \(receivedEvent) instead.",
                file: file, line: line
            )
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
