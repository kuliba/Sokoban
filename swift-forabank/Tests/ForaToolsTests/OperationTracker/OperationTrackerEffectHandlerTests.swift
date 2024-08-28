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
        
        let (_, loadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoad() {
        
        let (sut, loadSpy) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(loadSpy.callCount, 1)
    }
    
    func test_load_shouldDeliverLoadFailureEvent() {
        
        let (sut, loadSpy) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loadFailure) {
            
            loadSpy.complete(with: false)
        }
    }
    
    func test_load_shouldDeliverLoadSuccessEvent() {
        
        let (sut, loadSpy) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loadSuccess) {
            
            loadSpy.complete(with: true)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OperationTrackerEffectHandler
    private typealias LoadSpy = Spy<Void, Bool>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let sut = SUT(load: loadSpy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy)
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
