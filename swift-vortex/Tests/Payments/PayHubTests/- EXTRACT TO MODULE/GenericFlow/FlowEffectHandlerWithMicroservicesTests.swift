//
//  FlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import XCTest

final class FlowEffectHandlerWithMicroservicesTests: FlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, getNavigation) = makeSUT()
        
        XCTAssertEqual(getNavigation.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - getNavigation
    
    func test_getNavigation_shouldCallGetNavigationWithSelect() {
        
        let select = makeSelect()
        let (sut, getNavigation) = makeSUT()
        
        sut.handleEffect(.select(select)) { _ in }
        
        XCTAssertNoDiff(getNavigation.payloads, [select])
    }
    
    func test_getNavigation_shouldDeliverNavigation() {
        
        let navigation = makeNavigation()
        let (sut, getNavigation) = makeSUT()
        
        expect(
            sut,
            with: .select(makeSelect()),
            toDeliver: .navigation(navigation),
            on: { getNavigation.complete(with: navigation) }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FlowEffectHandler<Select, Navigation>
    private typealias GetNavigationSpy = Spy<Select, Navigation>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getNavigation: GetNavigationSpy
    ) {
        let getNavigation = GetNavigationSpy()
        let sut = SUT(
            microServices: .init(
                getNavigation: getNavigation.process
            ),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getNavigation, file: file, line: line)
        
        return (sut, getNavigation)
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
