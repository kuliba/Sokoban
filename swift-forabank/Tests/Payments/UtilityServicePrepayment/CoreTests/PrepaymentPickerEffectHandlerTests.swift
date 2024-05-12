//
//  PrepaymentPickerEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 12.05.2024.
//

import XCTest

final class PrepaymentPickerEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, paginateSpy) = makeSUT()
        
        XCTAssertEqual(paginateSpy.callCount, 0)
    }
    
    func test_paginate_shouldCallPaginateWithPayload() {
        
        let (operatorID, pageSize) = (makeOperatorID(), makePageSize())
        let (sut, paginateSpy) = makeSUT()
        
        sut.handleEffect(.paginate(operatorID, pageSize)) { _ in }
        
        XCTAssertNoDiff(paginateSpy.payloads.map(\.0), [operatorID])
        XCTAssertNoDiff(paginateSpy.payloads.map(\.1), [pageSize])
    }
    
    func test_paginate_shouldDeliverPageEventWithPayload() {
        
        let payload = [makeOperator()]
        let (sut, paginateSpy) = makeSUT()
        
        expect(sut, with: makePaginateEffect(), toDeliver: .page(payload)) {
            
            paginateSpy.complete(with: payload)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrepaymentPickerEffectHandler<Operator>
    private typealias PaginateSpy = Spy<(Operator.ID, Effect.PageSize), [Operator]>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        paginateSpy: PaginateSpy
    ) {
        let paginateSpy = PaginateSpy()
        let sut = SUT(
            paginate: paginateSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(paginateSpy, file: file, line: line)
        
        return (sut, paginateSpy)
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
