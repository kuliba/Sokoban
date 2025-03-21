//
//  EffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 21.03.2025.
//

final class EffectHandler {}

extension EffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension EffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CreditCardMVPCoreTests.Event
    typealias Effect = CreditCardMVPCoreTests.Effect
}

import XCTest

final class EffectHandlerTests: XCTestCase {

    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, load) = makeSUT()
        
        XCTAssertEqual(load.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - ???

    // MARK: - Helpers
    
    private typealias SUT = EffectHandler
    private typealias LoadSpy = Spy<Void, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        load: LoadSpy
    ) {
        let load = LoadSpy()
        let sut = SUT()//load: load.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(load, file: file, line: line)
        
        return (sut, load)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
