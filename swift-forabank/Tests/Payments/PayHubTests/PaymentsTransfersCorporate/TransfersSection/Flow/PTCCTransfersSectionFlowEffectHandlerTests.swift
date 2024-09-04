//
//  PTCCTransfersSectionFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

struct PTCCTransfersSectionFlowEffectHandlerMicroServices<Navigation, Select> {
    
    let makeNavigation: MakeNavigation
}

extension PTCCTransfersSectionFlowEffectHandlerMicroServices {
    
    typealias MakeNavigation = (Select, @escaping (Navigation) -> Void) -> Void
}

final class PTCCTransfersSectionFlowEffectHandler<Navigation, Select> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PTCCTransfersSectionFlowEffectHandlerMicroServices<Navigation, Select>
}

extension PTCCTransfersSectionFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            microServices.makeNavigation(select) { dispatch(.navigation($0)) }
        }
    }
}

extension PTCCTransfersSectionFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PTCCTransfersSectionFlowEvent<Navigation, Select>
    typealias Effect = PTCCTransfersSectionFlowEffect<Select>
}

import XCTest

final class PTCCTransfersSectionFlowEffectHandlerTests: PTCCTransfersSectionFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeNavigationSpy) = makeSUT()
        
        XCTAssertEqual(makeNavigationSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_shouldCallMakeNavigationWithSelection() {
        
        let select = makeSelect()
        let (sut, makeNavigationSpy) = makeSUT()
        
        sut.handleEffect(.select(select)) { _ in }
        
        XCTAssertNoDiff(makeNavigationSpy.payloads, [select])
    }
    
    func test_select_shouldDeliverNavigation() {
        
        let navigation = makeNavigation()
        let (sut, makeNavigationSpy) = makeSUT()
        
        expect(sut, with: .select(makeSelect()), toDeliver: .navigation(navigation)) {
            
            makeNavigationSpy.complete(with: navigation)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PTCCTransfersSectionFlowEffectHandler<Navigation, Select>
    private typealias MakeNavigationSpy = Spy<Select, Navigation>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeNavigationSpy: MakeNavigationSpy
    ) {
        let makeNavigationSpy = MakeNavigationSpy()
        let sut = SUT(microServices: .init(
            makeNavigation: makeNavigationSpy.process(_:completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, makeNavigationSpy)
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
