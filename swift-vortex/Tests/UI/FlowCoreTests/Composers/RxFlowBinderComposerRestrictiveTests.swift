//
//  RxFlowBinderComposerRestrictiveTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

import FlowCore
import XCTest

final class RxFlowBinderComposerRestrictiveTests: XCTestCase {
    
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
    
    func test_shouldNotMessageContentOnFlowIsLoading() {
        
        let (binder, _) = makeSUT()
        
        binder.flow.event(.isLoading(true))
        binder.flow.event(.isLoading(false))
        
        XCTAssertEqual(binder.content.callCount, 0)
    }
    
    // MARK: - Content to Flow
    
    func test_shouldSetFlowStateIsLoadingToTrue_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (binder, _) = makeSUT()
        let flowSpy = ValueSpy(binder.flow.$state)
        
        binder.content.emit(select)
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
        ])
    }
    
    func test_shouldMessageGetNavigationWithSelect_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (binder, getNavigation) = makeSUT()
        
        binder.content.emit(select)
        
        XCTAssertNoDiff(getNavigation.payloads, [select])
    }
    
    // MARK: - Helpers
    
    private typealias Content = EmitterReceiver<Select, Void>
    private typealias SUT = RxFlowBinderComposer
    private typealias Binder = FlowCore.Binder<Content, FlowDomain<Select, Navigation>.Flow>
    private typealias GetNavigationSpy = Spy<Select, Navigation>
    private typealias FlowState = FlowDomain<Select, Navigation>.State
    
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
            scheduler: .immediate
        )
        let binder = sut.compose(
            initialState: initialState,
            makeContent: { content },
            getNavigation: { getNavigation.process($0, completion: $2) },
            witnesses: content.selectWitnesses()
        )
        
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
