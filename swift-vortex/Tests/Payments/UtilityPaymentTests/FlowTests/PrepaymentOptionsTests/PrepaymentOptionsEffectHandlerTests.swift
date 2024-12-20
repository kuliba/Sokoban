//
//  PrepaymentOptionsEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 20.02.2024.
//

import UtilityPayment
import XCTest

final class PrepaymentOptionsEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, operatorsLoader, _) = makeSUT()
        
        XCTAssertEqual(operatorsLoader.callCount, 0)
    }
    
    // MARK: - paginate
    
    func test_paginate_shouldCallLoadOperatorWithPayload() {
        
        let (operatorID, pageSize) = anyPayload()
        let (sut, operatorsLoader, _) = makeSUT()
        
        sut.handleEffect(.paginate(operatorID, pageSize), { _ in })
        
        XCTAssertEqual(operatorsLoader.payloads.map(\.0), [operatorID])
        XCTAssertEqual(operatorsLoader.payloads.map(\.1), [pageSize])
    }
    
    func test_paginate_shouldDeliverLoadOperatorEmptyResult() {
        
        let (operatorID, pageSize) = anyPayload()
        let (sut, operatorsLoader, _) = makeSUT()
        
        expect(sut, with: .paginate(operatorID, pageSize), toDeliver: .paginated(.success([]))) {
            
            operatorsLoader.complete(with: .success([]))
        }
    }
    
    func test_paginate_shouldDeliverLoadOperatorResult() {
        
        let (operatorID, pageSize) = anyPayload()
        let (sut, operatorsLoader, _) = makeSUT()
        
        expect(sut, with: .paginate(operatorID, pageSize), toDeliver: .paginated(.success(.stub))) {
            
            operatorsLoader.complete(with: .success(.stub))
        }
    }
    
    // MARK: - search
    
    func test_search_shouldDebounceForSetInterval() {
        
        let (sut, _, scheduler) = makeSUT(
            debounce: .milliseconds(150)
        )
        let exp = expectation(description: "wait for completion")
        var event: Event?
        
        sut.handleEffect(.search("abc")) {
            
            event = $0
            exp.fulfill()
        }
        
        XCTAssertNil(event)
        
        scheduler.advance(to: .init(.now() + .milliseconds(149)))
        XCTAssertNil(event)
        
        scheduler.advance(to: .init(.now() + .milliseconds(150)))
        XCTAssertNoDiff(event, .search(.updated("abc")))
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrepaymentOptionsEffectHandler<LastPayment, Operator>
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
        
    private func makeSUT(
        debounce: DispatchTimeInterval = .milliseconds(500),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        operatorsLoader: LoadOperatorsSpy,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let operatorsLoader = LoadOperatorsSpy()
        let scheduler = DispatchQueue.test
        let sut = SUT(
            debounce: debounce,
            loadOperators: operatorsLoader.process(_:completion:),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(operatorsLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, operatorsLoader, scheduler)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
    
    private func anyPayload(
        operatorID: Operator.ID = UUID().uuidString,
        pageSize: Int = 789
    ) -> (Operator.ID, Int) {
        
        (operatorID, pageSize)
    }
}
