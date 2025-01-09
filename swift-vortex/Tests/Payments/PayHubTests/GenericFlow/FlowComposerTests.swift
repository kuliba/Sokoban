//
//  FlowComposerTests.swift
//
//
//  Created by Igor Malyarov on 28.09.2024.
//

import PayHub
import XCTest

final class FlowComposerTests: XCTestCase {
    
    func test_compose_shouldSetInitialState() {
        
        let navigation = makeNavigation()
        let initialState = makeState(isLoading: true, navigation: navigation)
        let (sut, _) = makeSUT()
        
        let flow = sut.compose(initialState: initialState)
        let spy = ValueSpy(flow.$state)
        
        XCTAssertNoDiff(spy.values, [.init(isLoading: true, navigation: navigation)])
    }
    
    func test_compose_shouldSetDefaultInitialState() {
        
        let (sut, _) = makeSUT()
        
        let flow = sut.compose()
        let spy = ValueSpy(flow.$state)
        
        XCTAssertNoDiff(spy.values, [.init(isLoading: false, navigation: nil)])
    }
    
    func test_composed_shouldNotCallGetNavigationOnDismissEvent() {
        
        let (sut, getNavigation) = makeSUT()
        let flow = sut.compose()
        
        flow.event(.dismiss)
        
        XCTAssertNoDiff(getNavigation.payloads.map(\.0), [])
    }
    
    func test_composed_shouldNotCallGetNavigationOnReceiveEvent() {
        
        let (sut, getNavigation) = makeSUT()
        let flow = sut.compose()
        
        flow.event(.navigation(makeNavigation()))
        
        XCTAssertNoDiff(getNavigation.payloads.map(\.0), [])
    }
    
    func test_composed_shouldCallGetNavigationWithSelectOnSelectEvent() {
        
        let select = makeSelect()
        let (sut, getNavigation) = makeSUT()
        let flow = sut.compose()
        
        flow.event(.select(select))
        
        XCTAssertNoDiff(getNavigation.payloads.map(\.0), [select])
    }
    
    func test_composed_shouldChangeStateOnNotifyWithDismiss() throws {
        
        let navigation = makeNavigation()
        let (sut, getNavigation) = makeSUT()
        let flow = sut.compose()
        let spy = ValueSpy(flow.$state)
        
        flow.event(.select(makeSelect()))
        getNavigation.complete(with: navigation)
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true, navigation: nil),
            .init(navigation: navigation)
        ])
        
        let notify = try XCTUnwrap(getNavigation.payloads.map(\.1).first)
        notify(.dismiss)
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true, navigation: nil),
            .init(navigation: navigation),
            .init()
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FlowComposer<Select, Navigation>
    private typealias Notify = SUT.MicroServices.Notify
    private typealias GetNavigationSpy = Spy<(Select, Notify), Navigation>
    
    private func makeSUT(
        delay: SUT.Delay = .milliseconds(100),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getNavigationSpy: GetNavigationSpy
    ) {
        let getNavigation = GetNavigationSpy()
        let sut = SUT(
            delay: delay,
            getNavigation:  {
                
                getNavigation.process(($0, $1), completion: $2)
            },
            scheduler: .immediate,
            interactiveScheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getNavigation, file: file, line: line)
        
        return (sut, getNavigation)
    }
    
    private struct Select: Equatable {
        
        let value: String
    }
    
    private func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
    
    private struct Navigation: Equatable {
        
        let value: String
    }
    
    private func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
    
    private func makeState(
        isLoading: Bool = false,
        navigation: Navigation? = nil
    ) -> SUT.Domain.State {
        
        return .init(isLoading: isLoading, navigation: navigation)
    }
}
