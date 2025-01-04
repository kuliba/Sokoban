//
//  ContentFlowBindingFactoryRxFlowTests.swift
//
//
//  Created by Igor Malyarov on 03.01.2025.
//

import Combine
import FlowCore
import XCTest

final class ContentFlowBindingFactoryRxFlowTests: XCTestCase {
    
    func test_init_shouldNotMessage() {
        
        let (content, flow, flowSpy, getNavigation, cancellables) = makeSUT()
        
        XCTAssertEqual(content.callCount, 0)
        XCTAssertNil(flow.state.navigation)
        XCTAssertEqual(flowSpy.values.count, 1)
        XCTAssertEqual(getNavigation.callCount, 0)
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Flow to Content
    
    func test_shouldNotMessageContentOnNavigation() {
        
        let (content, flow, _,_, cancellables) = makeSUT()
        
        flow.event(.navigation(makeNavigation()))
        
        XCTAssertEqual(content.callCount, 0)
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldNotMessageContentOnSecondNavigation() {
        
        let (content, flow, _,_, cancellables) = makeSUT()
        
        flow.event(.navigation(makeNavigation()))
        flow.event(.navigation(makeNavigation()))
        
        XCTAssertEqual(content.callCount, 0)
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldMessageContentOnDismissAfterNonNilNavigation() {
        
        let (content, flow, _,_, cancellables) = makeSUT()
        
        flow.event(.navigation(makeNavigation()))
        flow.event(.dismiss)
        
        XCTAssertEqual(content.callCount, 1)
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldNotMessageContentOnSecondDismissAfterNonNilNavigation() {
        
        let (content, flow, _,_, cancellables) = makeSUT()
        
        flow.event(.navigation(makeNavigation()))
        flow.event(.dismiss)
        flow.event(.dismiss)
        
        XCTAssertEqual(content.callCount, 1)
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Content to Flow
    
    func test_shouldFlowStateIsLoadingTrue_onContentEmittingIsLoadingTrue() {
        
        let (content, _, flowSpy, _, cancellables) = makeSUT()
        
        content.emit(.isLoading(true))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false),
            .init(isLoading: true),
        ])
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldSetFlowStateIsLoadingFalse_onContentEmittingIsLoadingFalse() {
        
        let (content, _, flowSpy, _, cancellables) = makeSUT()
        
        content.emit(.isLoading(false))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false),
            .init(isLoading: false),
        ])
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldSetFlowStateIsLoadingToTrue_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (content, _, flowSpy, _, cancellables) = makeSUT()
        
        content.emit(.select(select))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
        ])
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldMessageGetNavigationWithSelect_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (content, _,_, getNavigation, cancellables) = makeSUT()
        
        content.emit(.select(select))
        
        XCTAssertNoDiff(getNavigation.payloads, [select])
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldResetFlowState_onContentEmittingDismiss() {
        
        let navigation = makeNavigation()
        let (content, _, flowSpy, getNavigation, cancellables) = makeSUT()
        
        content.emit(.select(makeSelect()))
        getNavigation.complete(with: navigation)
        content.emit(.dismiss)
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
            .init(isLoading: false, navigation: navigation),
            .init(isLoading: false, navigation: nil),
        ])
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ContentFlowBindingFactory
    private typealias Content = EmitterReceiver<FlowEvent<Select, Never>, Void>
    private typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    private typealias Flow = FlowDomain.Flow
    private typealias FlowSpy = ValueSpy<FlowDomain.State>
    private typealias GetNavigationSpy = Spy<Select, Navigation>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        content: Content,
        flow: Flow,
        flowSpy: FlowSpy,
        getNavigation: GetNavigationSpy,
        cancellables: Set<AnyCancellable>
    ) {
        let sut = SUT()
        let content = Content()
        
        let getNavigation = GetNavigationSpy()
        let composer = FlowDomain.Composer(
            getNavigation: { getNavigation.process($0, completion: $2) },
            scheduler: .immediate
        )
        let flow = composer.compose()
        let flowSpy = FlowSpy(flow.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(getNavigation, file: file, line: line)
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(flow, file: file, line: line)
        trackForMemoryLeaks(flowSpy, file: file, line: line)
        
        let cancellables = sut.bind(content: content, flow: flow, witnesses: witnesses)
        
        return (content, flow, flowSpy, getNavigation, cancellables)
    }
    
    private let witnesses = ContentWitnesses<Content, FlowEvent<Select, Never>>(
        emitting: { $0.publisher },
        dismissing: { content in { content.receive(()) }}
    )
    
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
}
