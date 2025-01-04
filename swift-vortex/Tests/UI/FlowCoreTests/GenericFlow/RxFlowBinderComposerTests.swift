//
//  RxFlowBinderComposerTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

import FlowCore
import XCTest

final class RxFlowBinderComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getNavigation) = makeSUT()
        
        XCTAssertEqual(getNavigation.callCount, 0)
    }
    
    func test_compose_shouldSetInitialFlowState() {
        
        let initialState = makeFlowState(
            isLoading: true,
            navigation: makeNavigation()
        )
        let (binder, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(binder.flow.state, initialState)
    }
    
    // MARK: - Flow to Content
    
    func test_shouldNotMessageContentOnFlowNavigation() {
        
        let (binder, _) = makeSUT()
        
        binder.flow.event(.navigation(makeNavigation()))
        
        XCTAssertEqual(binder.content.callCount, 0)
    }
    
    func test_shouldNotMessageContentOnSecondNavigation() {
        
        let (binder, _) = makeSUT()
        
        binder.flow.event(.navigation(makeNavigation()))
        binder.flow.event(.navigation(makeNavigation()))
        
        XCTAssertEqual(binder.content.callCount, 0)
    }
    
    func test_shouldMessageContentOnDismissAfterNonNilNavigation() {
        
        let (binder, _) = makeSUT()
        
        binder.flow.event(.navigation(makeNavigation()))
        binder.flow.event(.dismiss)
        
        XCTAssertEqual(binder.content.callCount, 1)
    }
    
    func test_shouldNotMessageContentOnSecondDismissAfterNonNilNavigation() {
        
        let (binder, _) = makeSUT()
        
        binder.flow.event(.navigation(makeNavigation()))
        binder.flow.event(.dismiss)
        binder.flow.event(.dismiss)
        
        XCTAssertEqual(binder.content.callCount, 1)
    }
    
    // MARK: - Content to Flow
    
    func test_shouldSetFlowStateIsLoadingToTrue_onContentEmittingIsLoadingTrue() {
        
        let (binder, _) = makeSUT()
        let flowSpy = ValueSpy(binder.flow.$state)
        
        binder.content.emit(.isLoading(true))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false),
            .init(isLoading: true),
        ])
    }
    
    func test_shouldSetFlowStateIsLoadingToFalse_onContentEmittingIsLoadingFalse() {
        
        let (binder, _) = makeSUT(initialState: .init(isLoading: true))
        let flowSpy = ValueSpy(binder.flow.$state)
        
        binder.content.emit(.isLoading(false))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: true),
            .init(isLoading: false),
        ])
    }
    
    func test_shouldSetFlowStateIsLoadingToTrue_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (binder, _) = makeSUT()
        let flowSpy = ValueSpy(binder.flow.$state)
        
        binder.content.emit(.select(select))
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
        ])
    }
    
    func test_shouldMessageGetNavigationWithSelect_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (binder, getNavigation) = makeSUT()
        
        binder.content.emit(.select(select))
        
        XCTAssertNoDiff(getNavigation.payloads, [select])
    }
    
    func test_shouldResetFlowState_onContentEmittingDismiss() {
        
        let navigation = makeNavigation()
        let (binder, getNavigation) = makeSUT()
        let flowSpy = ValueSpy(binder.flow.$state)
        
        binder.content.emit(.select(makeSelect()))
        getNavigation.complete(with: navigation)
        binder.content.emit(.dismiss)
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
            .init(isLoading: false, navigation: navigation),
            .init(isLoading: false, navigation: nil),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Content = EmitterReceiver<FlowEvent<Select, Never>, Void>
    private typealias SUT = RxFlowBinderComposer<Content, Select, Navigation>
    private typealias Binder = SUT.Binder
    private typealias GetNavigationSpy = Spy<Select, Navigation>
    private typealias FlowState = SUT.FlowDomain.State
    
    private func makeSUT(
        initialState: FlowState = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        binder: Binder,
        getNavigation: GetNavigationSpy
    ) {
        let getNavigation = GetNavigationSpy()
        let content = Content()
        let sut = SUT(
            makeContent: { content },
            getNavigation: { getNavigation.process($0, completion: $2) },
            witnesses: content.witnesses(),
            scheduler: .immediate
        )
        let binder = sut.compose(initialState: initialState)
        
        trackForMemoryLeaks(getNavigation, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(binder, file: file, line: line)
        
        return (binder, getNavigation)
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
