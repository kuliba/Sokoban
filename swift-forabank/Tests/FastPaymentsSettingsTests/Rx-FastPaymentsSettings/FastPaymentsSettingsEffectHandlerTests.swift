//
//  FastPaymentsSettingsEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

final class FastPaymentsSettingsEffectHandler {
    
}

extension FastPaymentsSettingsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError("unimplemented")
    }
}

extension FastPaymentsSettingsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

import FastPaymentsSettings
import XCTest

final class FastPaymentsSettingsEffectHandlerTests: XCTestCase {
    
    func test_() {
        
        _ = makeSUT()
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvent: Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) {
            
            XCTAssertNoDiff($0, expectedEvent, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
