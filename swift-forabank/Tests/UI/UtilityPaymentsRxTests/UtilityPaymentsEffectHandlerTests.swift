//
//  UtilityPaymentsEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 20.02.2024.
//

import UtilityPaymentsRx
import XCTest

final class UtilityPaymentsEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loadLastPaymentsSpy, loadOperatorsSpy, _) = makeSUT()
        
        XCTAssertEqual(loadLastPaymentsSpy.callCount, 0)
        XCTAssertEqual(loadOperatorsSpy.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldCallLoaders() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _) = makeSUT()
        
        sut.handleEffect(.initiate, { _ in })
        
        XCTAssertEqual(loadLastPaymentsSpy.callCount, 1)
        XCTAssertEqual(loadOperatorsSpy.callCount, 1)
    }
    
    func test_initiate_shouldCallLoadOperatorWithNilPayload() {
        
        let (sut, _, loadOperatorsSpy, _) = makeSUT()
        
        sut.handleEffect(.initiate, { _ in })
        
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.0), [nil])
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.1), [nil])
    }
    
    func test_initiate_shouldDeliverFailureLoadResults() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.lastPayments(.failure(.connectivityError))), .loaded(.operators(.failure(.connectivityError)))) {
            
            loadLastPaymentsSpy.complete(with: .failure(.connectivityError))
            loadOperatorsSpy.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_initiate_shouldDeliverEmptyLoadResults() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.lastPayments(.success([]))), .loaded(.operators(.success([])))) {
            
            loadLastPaymentsSpy.complete(with: .success([]))
            loadOperatorsSpy.complete(with: .success([]))
        }
    }
    
    func test_initiate_shouldDeliverLoadResults() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.lastPayments(.success(.stub))), .loaded(.operators(.success(.stub)))) {
            
            loadLastPaymentsSpy.complete(with: .success(.stub))
            loadOperatorsSpy.complete(with: .success(.stub))
        }
    }
    
    // MARK: - paginate
    
    func test_paginate_shouldCallLoadOperatorWithPayload() {
        
        let (operatorID, pageSize) = anyPayload()
        let (sut, _, loadOperatorsSpy, _) = makeSUT()
        
        sut.handleEffect(.paginate(operatorID, pageSize), { _ in })
        
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.0), [operatorID])
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.1), [pageSize])
    }
    
    func test_paginate_shouldDeliverLoadOperatorEmptyResult() {
        
        let (operatorID, pageSize) = anyPayload()
        let (sut, _, loadOperatorsSpy, _) = makeSUT()
        
        expect(sut, with: .paginate(operatorID, pageSize), toDeliver: .paginated(.success([]))) {
            
            loadOperatorsSpy.complete(with: .success([]))
        }
    }
    
    func test_paginate_shouldDeliverLoadOperatorResult() {
        
        let (operatorID, pageSize) = anyPayload()
        let (sut, _, loadOperatorsSpy, _) = makeSUT()
        
        expect(sut, with: .paginate(operatorID, pageSize), toDeliver: .paginated(.success(.stub))) {
            
            loadOperatorsSpy.complete(with: .success(.stub))
        }
    }
    
    // MARK: - search
    
    func test_search_shouldDebounceForSetInterval() {
        
        let (sut, _,_, scheduler) = makeSUT(
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
    
    private typealias SUT = UtilityPaymentsEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias LoadLastPaymentsSpy = Spy<Void, LoadLastPaymentsResult>
    private typealias LoadOperatorsSpy = Spy<SUT.LoadOperatorsPayload?, LoadOperatorsResult>
    
    private func makeSUT(
        debounce: DispatchTimeInterval = .milliseconds(500),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadLastPaymentsSpy: LoadLastPaymentsSpy,
        loadOperatorsSpy: LoadOperatorsSpy,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let loadLastPaymentsSpy = LoadLastPaymentsSpy()
        let loadOperatorsSpy = LoadOperatorsSpy()
        let scheduler = DispatchQueue.test
        let sut = SUT(
            debounce: debounce,
            loadLastPayments: loadLastPaymentsSpy.process(completion:),
            loadOperators: loadOperatorsSpy.process(_:completion:),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(loadLastPaymentsSpy, file: file, line: line)
        trackForMemoryLeaks(loadOperatorsSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loadLastPaymentsSpy, loadOperatorsSpy, scheduler)
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
        operatorID: Operator.ID = .init(UUID().uuidString),
        pageSize: Int = 789
    ) -> SUT.LoadOperatorsPayload {
        
        (operatorID, pageSize)
    }
}
