//
//  PrepaymentPickerEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentCore
import XCTest

final class PrepaymentPickerEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, paginateSpy) = makeSUT()
        
        XCTAssertEqual(paginateSpy.callCount, 0)
    }
    
    // MARK: - paginate
    
    func test_paginate_shouldCallPaginateWithPayload() {
        
        let payload = makePaginatePayload()
        let (sut, paginateSpy) = makeSUT()
        
        sut.handleEffect(.paginate(payload)) { _ in }
        
        XCTAssertNoDiff(paginateSpy.payloads, [
            .init(
                operatorID: payload.operatorID,
                pageSize: payload.pageSize,
                searchText: payload.searchText
            )
        ])
    }
    
    func test_paginate_shouldDeliverPageEventWithPayload() {
        
        let payload = [makeOperator()]
        let (sut, paginateSpy) = makeSUT()
        
        expect(sut, with: makePaginateEffect(), toDeliver: .page(payload)) {
            
            paginateSpy.complete(with: payload)
        }
    }
    
    // MARK: - search
    
//    func test_search_shouldCallPaginateWithPayload() {
//        
//        let payload = makePaginatePayload()
//        let (sut, paginateSpy) = makeSUT()
//        
//        sut.handleEffect(.search(text)) { _ in }
//        
//        XCTAssertNoDiff(paginateSpy.payloads, [
//            .init(op)
//        ])
//    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrepaymentPickerEffectHandler<Operator>
    private typealias PaginateSpy = Spy<Effect.PaginatePayload, [Operator]>
    
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
