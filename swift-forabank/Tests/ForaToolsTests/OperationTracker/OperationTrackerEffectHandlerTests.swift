//
//  OperationTrackerEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

import ForaTools
import XCTest

final class OperationTrackerEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, startSpy) = makeSUT()
        
        XCTAssertEqual(startSpy.callCount, 0)
    }
    
    // MARK: - start
    
    func test_start_shouldCallStart() {
        
        let (sut, startSpy) = makeSUT()
        
        sut.handleEffect(.start) { _ in }
        
        XCTAssertEqual(startSpy.callCount, 1)
    }
    
    func test_start_shouldDeliverStartFailureEvent() {
        
        let (sut, startSpy) = makeSUT()
        
        expect(sut, with: .start, toDeliver: .fail) {
            
            startSpy.complete(with: false)
        }
    }
    
    func test_start_shouldDeliverStartSuccessEvent() {
        
        let (sut, startSpy) = makeSUT()
        
        expect(sut, with: .start, toDeliver: .succeed) {
            
            startSpy.complete(with: true)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OperationTrackerEffectHandler
    private typealias StartSpy = Spy<Void, Bool>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        startSpy: StartSpy
    ) {
        let startSpy = StartSpy()
        let sut = SUT(start: startSpy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(startSpy, file: file, line: line)
        
        return (sut, startSpy)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
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
