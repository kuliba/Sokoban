//
//  ComposeBinderTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

import FlowCore
import XCTest

final class ComposeBinderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getNavigation) = makeSUT()
        
        XCTAssertEqual(getNavigation.callCount, 0)
    }
    
    func test_compose_shouldSetInitialFlowState() {
        
        let initialState = makeFlowState(
            isLoading: true,
            navigation: makeNavigation()
        )
        let (sut, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(sut.flow.state, initialState)
    }
    
    // MARK: - Flow to Content
    
    func test_shouldNotMessageContentOnFlowNavigation() {
        
        let (sut, _) = makeSUT()
        
        sut.flow.event(.navigation(makeNavigation()))
        
        XCTAssertEqual(sut.content.callCount, 0)
    }
    
    func test_shouldNotMessageContentOnSecondNavigation() {
        
        let (sut, _) = makeSUT()
        
        sut.flow.event(.navigation(makeNavigation()))
        sut.flow.event(.navigation(makeNavigation()))
        
        XCTAssertEqual(sut.content.callCount, 0)
    }
    
    func test_shouldMessageContentOnDismissAfterNonNilNavigation() {
        
        let (sut, _) = makeSUT()
        
        sut.flow.event(.navigation(makeNavigation()))
        sut.flow.event(.dismiss)
        
        XCTAssertEqual(sut.content.callCount, 1)
    }
    
    func test_shouldNotMessageContentOnSecondDismissAfterNonNilNavigation() {
        
        let (sut, _) = makeSUT()
        
        sut.flow.event(.navigation(makeNavigation()))
        sut.flow.event(.dismiss)
        sut.flow.event(.dismiss)
        
        XCTAssertEqual(sut.content.callCount, 1)
    }
    
    func test_shouldNotMessageContentOnFlowIsLoading() {
        
        let (sut, _) = makeSUT()
        
        sut.flow.event(.isLoading(true))
        sut.flow.event(.isLoading(false))
        
        XCTAssertEqual(sut.content.callCount, 0)
    }
    
    // MARK: - Content to Flow
    
    func test_shouldSetFlowStateIsLoadingToTrue_onContentEmittingIsLoadingTrue() {
        
        let (sut, _) = makeSUT()
        let flowSpy = ValueSpy(sut.flow.$state)
        
        sut.content.emit(.isLoading(true))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false),
            .init(isLoading: true),
        ])
    }
    
    func test_shouldSetFlowStateIsLoadingToFalse_onContentEmittingIsLoadingFalse() {
        
        let (sut, _) = makeSUT(initialState: .init(isLoading: true))
        let flowSpy = ValueSpy(sut.flow.$state)
        
        sut.content.emit(.isLoading(false))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: true),
            .init(isLoading: false),
        ])
    }
    
    func test_shouldSetFlowStateIsLoadingToTrue_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (sut, _) = makeSUT()
        let flowSpy = ValueSpy(sut.flow.$state)
        
        sut.content.emit(.select(select))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
        ])
    }
    
    func test_shouldMessageGetNavigationWithSelect_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (sut, getNavigation) = makeSUT()
        
        sut.content.emit(.select(select))
        
        XCTAssertNoDiff(getNavigation.payloads, [select])
    }
    
    func test_shouldResetFlowState_onContentEmittingDismiss() {
        
        let navigation = makeNavigation()
        let (sut, getNavigation) = makeSUT()
        let flowSpy = ValueSpy(sut.flow.$state)
        
        sut.content.emit(.select(makeSelect()))
        getNavigation.complete(with: navigation)
        sut.content.emit(.dismiss)
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
            .init(isLoading: false, navigation: navigation),
            .init(isLoading: false, navigation: nil),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Domain = FlowDomain<Select, Navigation>
    private typealias Content = EmitterReceiver<FlowEvent<Select, Never>, Void>
    private typealias Flow = Domain.Flow
    private typealias SUT = FlowCore.Binder<Content, Flow>
    private typealias GetNavigationSpy = Spy<Select, Navigation>
    private typealias FlowState = Domain.State

    private func makeSUT(
        initialState: FlowState = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getNavigation: GetNavigationSpy
    ) {
        let getNavigation = GetNavigationSpy()
        let content = Content()
        let witnesses = content.witnesses()
        let flowComposer = FlowComposer(
            getNavigation: { getNavigation.process($0, completion: $2) },
            scheduler: .immediate
        )
        let flow = flowComposer.compose(initialState: initialState)
        let sut = witnesses.composeBinder(content: content, flow: flow)

        trackForMemoryLeaks(getNavigation, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(flowComposer, file: file, line: line)
        trackForMemoryLeaks(flow, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, getNavigation)
    }
    
    private func makeFlowState(
        isLoading: Bool = false,
        navigation: Navigation? = nil
    ) -> FlowState {
        
        return .init(isLoading: isLoading, navigation: navigation)
    }
    
    private struct Navigation: Equatable {
        
        let value: String
    }
    
    private func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
    
    private struct Select: Equatable {
        
        let value: String
    }
    
    private func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
}
