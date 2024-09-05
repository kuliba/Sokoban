//
//  PickerFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import XCTest

final class PickerFlowEffectHandlerTests: PickerFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_shouldCallMakeNavigationWithPayload() {
        
        let element = makeElement()
        let (sut, spy) = makeSUT()
        
        sut.handleEffect(.select(element)) { _ in }
        
        XCTAssertEqual(spy.payloads, [element])
        XCTAssertNotNil(sut)
    }
    
    func test_select_shouldDeliverNavigation() {
        
        let navigation = makeNavigation()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .select(makeElement()), toDeliver: .navigation(navigation)) {
            
            spy.complete(with: navigation)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PickerFlowEffectHandler<Element, Navigation>
    private typealias MakeNavigationSpy = Spy<Element, Navigation>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: MakeNavigationSpy
    ) {
        let spy = MakeNavigationSpy()
        let sut = SUT(makeNavigation: spy.process(_:completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
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
