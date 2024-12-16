//
//  PlainPickerBinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import CombineSchedulers
import PayHub
import PayHubUI
import XCTest

final class PlainPickerBinderComposerTests: PlainPickerTests {
    
    // MARK - content to flow
    
    func test_shouldNotCallMakeNavigationWithPayloadOnNilContentSelect() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut.content.event(.select(nil))
        scheduler.advance()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallMakeNavigationWithPayloadOnNonNilContentSelect() {
        
        let element = makeElement()
        let (sut, spy, scheduler) = makeSUT()
        
        sut.content.event(.select(element))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.payloads.map(\.0), [element])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetNavigationOnNonNilContentSelect() {
        
        let navigation = makeNavigation()
        let (sut, spy, scheduler) = makeSUT()
        let flowSpy = ValueSpy(sut.flow.$state)
        XCTAssertNoDiff(flowSpy.values, [.init()])
        
        sut.content.event(.select(makeElement()))
        scheduler.advance()
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false),
            .init(isLoading: true),
        ])
        
        spy.complete(with: navigation)
        scheduler.advance()
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false),
            .init(isLoading: true),
            .init(isLoading: false, navigation: navigation)
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - flow to content
    
    func test_shouldResetContentSelectionOnFlowDismiss() {
        
        let element = makeElement()
        let (sut, spy, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state)
        XCTAssertNoDiff(contentSpy.values, [.init(elements: [])])
        
        sut.content.event(.select(element))
        scheduler.advance()
        spy.complete(with: makeNavigation())
        scheduler.advance()
        XCTAssertNoDiff(contentSpy.values, [
            .init(elements: []),
            .init(elements: [], selection: element)
        ])
        
        sut.flow.event(.dismiss)
        scheduler.advance(by: .milliseconds(100))
        XCTAssertNoDiff(contentSpy.values, [
            .init(elements: []),
            .init(elements: [], selection: element),
            .init(elements: []),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PlainPickerBinderComposer<Element, Navigation>
    private typealias SUT = PlainPickerBinder<Element, Navigation>
    private typealias MakeNavigationSpy = Spy<(Element, (FlowEvent<Element, Never>) -> Void), Navigation>
    
    private func makeSUT(
        elements: [PlainPickerTests.Element] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: MakeNavigationSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let spy = MakeNavigationSpy()
        let scheduler = DispatchQueue.test
        let composer = Composer(
            elements: elements,
            getNavigation: spy.process,
            schedulers: .init(
                main: scheduler.eraseToAnyScheduler(),
                interactive: .immediate
            )
        )
        let sut = composer.compose()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
}
