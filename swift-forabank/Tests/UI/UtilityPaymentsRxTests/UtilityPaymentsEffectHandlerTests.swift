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
        
        let (_, loadLastPaymentsSpy, loadOperatorsSpy, paginator, _) = makeSUT()
        
        XCTAssertEqual(loadLastPaymentsSpy.callCount, 0)
        XCTAssertEqual(loadOperatorsSpy.callCount, 0)
        XCTAssertEqual(paginator.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldCallLoaders() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        sut.handleEffect(.initiate, { _ in })
        
        XCTAssertEqual(loadLastPaymentsSpy.callCount, 1)
        XCTAssertEqual(loadOperatorsSpy.callCount, 1)
    }
    
    func test_initiate_shouldDeliverFailureLoadResults() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.lastPayments(.failure(.connectivityError))), .loaded(.operators(.failure(.connectivityError)))) {
            
            loadLastPaymentsSpy.complete(with: .failure(.connectivityError))
            loadOperatorsSpy.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_initiate_shouldDeliverEmptyLoadResults() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.lastPayments(.success([]))), .loaded(.operators(.success([])))) {
            
            loadLastPaymentsSpy.complete(with: .success([]))
            loadOperatorsSpy.complete(with: .success([]))
        }
    }
    
    func test_initiate_shouldDeliverLoadResults() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _,_) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.lastPayments(.success(.stub))), .loaded(.operators(.success(.stub)))) {
            
            loadLastPaymentsSpy.complete(with: .success(.stub))
            loadOperatorsSpy.complete(with: .success(.stub))
        }
    }
    
    // MARK: - paginate
    
    func test_paginate_shouldCallPaginator() {
        
        let (sut, _,_, paginator, _) = makeSUT()
        
        sut.handleEffect(.paginate, { _ in })
        
        XCTAssertEqual(paginator.callCount, 1)
    }
    
    func test_paginate_shouldDeliverPaginatorEmptyResult() {
        
        let (sut, _,_, paginator, _) = makeSUT()

        expect(sut, with: .paginate, toDeliver: .paginated([])) {
            
            paginator.complete(with: [])
        }
    }
    
    func test_paginate_shouldDeliverPaginatorResult() {
        
        let (sut, _,_, paginator, _) = makeSUT()
        
        expect(sut, with: .paginate, toDeliver: .paginated(.stub)) {
            
            paginator.complete(with: .stub)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentsEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias LoadLastPaymentsSpy = Spy<Void, LoadLastPaymentsResult>
    private typealias LoadOperatorsSpy = Spy<Void, LoadOperatorsResult>
    private typealias Paginator = Spy<Void, [Operator]>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadLastPaymentsSpy: LoadLastPaymentsSpy,
        loadOperatorsSpy: LoadOperatorsSpy,
        paginator: Paginator,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let loadLastPaymentsSpy = LoadLastPaymentsSpy()
        let loadOperatorsSpy = LoadOperatorsSpy()
        let paginator = Paginator()
        let scheduler = DispatchQueue.test
        let sut = SUT(
            loadLastPayments: loadLastPaymentsSpy.process(completion:),
            loadOperators: loadOperatorsSpy.process(completion:),
            paginate: paginator.process(completion:),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(loadLastPaymentsSpy, file: file, line: line)
        trackForMemoryLeaks(loadOperatorsSpy, file: file, line: line)
        trackForMemoryLeaks(paginator, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loadLastPaymentsSpy, loadOperatorsSpy, paginator, scheduler)
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
}
