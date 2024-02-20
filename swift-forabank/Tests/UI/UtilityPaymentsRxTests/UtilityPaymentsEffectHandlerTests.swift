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
    
    func test_initiate_shouldDeliverLoadResults() {
        
        let (sut, loadLastPaymentsSpy, loadOperatorsSpy, _,_) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 2
        var event: Event?
        
        sut.handleEffect(.initiate) {
            
            event = $0
            exp.fulfill()
        }
        loadLastPaymentsSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(event, .loaded(.lastPayments(.failure(.connectivityError))))
        
        loadOperatorsSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(event, .loaded(.operators(.failure(.connectivityError))))
        
        wait(for: [exp], timeout: 1)
    }

    // MARK: - paginate
    
    func test_paginate_shouldCallPaginator() {
        
        let (sut, _,_, paginator, _) = makeSUT()
        
        sut.handleEffect(.paginate, { _ in })
        
        XCTAssertEqual(paginator.callCount, 1)
    }
    
    func test_paginate_shouldDeliverPaginatorEmptyResult() {
        
        let (sut, _,_, paginator, _) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        var event: Event?
        
        sut.handleEffect(.paginate) {
            
            event = $0
            exp.fulfill()
        }
        paginator.complete(with: [])
        
        XCTAssertNoDiff(event, .paginated([]))
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_paginate_shouldDeliverPaginatorResult() {
        
        let (sut, _,_, paginator, _) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        var event: Event?
        
        sut.handleEffect(.paginate) {
            
            event = $0
            exp.fulfill()
        }
        paginator.complete(with: .stub)
        
        XCTAssertNoDiff(event, .paginated(.stub))
        
        wait(for: [exp], timeout: 1)
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
}
