//
//  PrepaymentPickerEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain
import UtilityServicePrepaymentCore
import XCTest

final class PrepaymentPickerEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, paginateSpy, searchSpy) = makeSUT()
        
        XCTAssertEqual(paginateSpy.callCount, 0)
        XCTAssertEqual(searchSpy.callCount, 0)
    }
    
    // MARK: - paginate
    
    func test_paginate_shouldCallPaginateWithPayload() {
        
        let payload = makePaginatePayload()
        let (sut, paginateSpy, _) = makeSUT()
        
        sut.handleEffect(.paginate(payload)) { _ in }
        
        XCTAssertNoDiff(paginateSpy.payloads, [
            .init(
                operatorID: payload.operatorID,
                searchText: payload.searchText
            )
        ])
    }
    
    func test_paginate_shouldDeliverPageEventWithEmptyOperators() {
        
        let operators = [Operator]()
        let (sut, paginateSpy, _) = makeSUT()
        
        expect(sut, with: makePaginateEffect(), toDeliver: .page(operators)) {
            
            paginateSpy.complete(with: operators)
        }
    }
    
    func test_paginate_shouldDeliverPageEventWithOneOperator() {
        
        let operators = [makeOperator()]
        let (sut, paginateSpy, _) = makeSUT()
        
        expect(sut, with: makePaginateEffect(), toDeliver: .page(operators)) {
            
            paginateSpy.complete(with: operators)
        }
    }
    
    func test_paginate_shouldDeliverPageEventWithTwoOperators() {
        
        let operators = [makeOperator(), makeOperator()]
        let (sut, paginateSpy, _) = makeSUT()
        
        expect(sut, with: makePaginateEffect(), toDeliver: .page(operators)) {
            
            paginateSpy.complete(with: operators)
        }
    }
    
    // MARK: - search
    
    func test_search_shouldCallPaginateWithPayload() {
        
        let searchText = anyMessage()
        let (sut, _, searchSpy) = makeSUT()
        
        sut.handleEffect(.search(searchText)) { _ in }
        
        XCTAssertNoDiff(searchSpy.payloads, [searchText])
    }
    
    func test_search_shouldDeliverPageEventWithEmptyOperators() {
        
        let operators = [Operator]()
        let (sut, _, searchSpy) = makeSUT()
        
        expect(sut, with: makeSearchEffect(), toDeliver: .load(operators)) {
            
            searchSpy.complete(with: operators)
        }
    }
    
    func test_search_shouldDeliverPageEventWithOneOperator() {
        
        let operators = [makeOperator()]
        let (sut, _, searchSpy) = makeSUT()
        
        expect(sut, with: makeSearchEffect(), toDeliver: .load(operators)) {
            
            searchSpy.complete(with: operators)
        }
    }
    
    func test_search_shouldDeliverPageEventWithTwoOperators() {
        
        let operators = [makeOperator(), makeOperator()]
        let (sut, _, searchSpy) = makeSUT()
        
        expect(sut, with: makeSearchEffect(), toDeliver: .load(operators)) {
            
            searchSpy.complete(with: operators)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrepaymentPickerEffectHandler<Operator>
    private typealias PaginateSpy = Spy<PaginatePayload<Operator.ID>, [Operator]>
    private typealias SearchSpy = Spy<String, [Operator]>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        paginateSpy: PaginateSpy,
        searchSpy: SearchSpy
    ) {
        let paginateSpy = PaginateSpy()
        let searchSpy = SearchSpy()
        let sut = SUT(
            paginate: paginateSpy.process(_:completion:),
            search: searchSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(paginateSpy, file: file, line: line)
        trackForMemoryLeaks(searchSpy, file: file, line: line)
        
        return (sut, paginateSpy, searchSpy)
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
