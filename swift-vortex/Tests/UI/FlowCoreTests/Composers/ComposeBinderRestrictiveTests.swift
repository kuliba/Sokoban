//
//  ComposeBinderRestrictiveTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

extension ContentWitnesses {
    
    /// Creates a `Binder` that connects the specified content with a flow configured for advanced scenarios.
    ///
    /// This overload supports advanced functionalities—such as handling loading states (`isLoading`) and dismiss actions—by using a flow whose event type is wrapped in `FlowEvent<S, Never>`.
    ///
    /// - Parameters:
    ///   - content: The content instance to be bound.
    ///   - flow: A flow from the flow domain of type `FlowDomain<S, Navigation>.Flow`, enabling advanced event handling.
    /// - Returns: A `Binder` that binds the content with the provided flow using the standard binding logic.
    func composeBinder<S, Navigation>(
        content: Content,
        flow: FlowDomain<S, Navigation>.Flow
    ) -> Binder<Content, FlowDomain<S, Navigation>.Flow>
    where Select == FlowEvent<S, Never> {
        
        return .init(content: content, flow: flow, bind: bind(content:flow:))
    }
    
    /// Creates a `Binder` that connects the specified content with a flow using a more restricted event mapping.
    ///
    /// This overload expects the flow's event type to directly match `Select`, mapping `Select` events into `FlowEvent.select(...)` only. It does not support advanced scenarios like `isLoading` or explicit dismiss actions.
    ///
    /// - Parameters:
    ///   - content: The content instance to be bound.
    ///   - flow: A flow from the flow domain of type `FlowDomain<Select, Navigation>.Flow`.
    /// - Returns: A `Binder` that binds the content with the provided flow using the standard binding logic.
    func composeBinder<Navigation>(
        content: Content,
        flow: FlowDomain<Select, Navigation>.Flow
    ) -> Binder<Content, FlowDomain<Select, Navigation>.Flow> {
        
        return .init(content: content, flow: flow, bind: bind(content:flow:))
    }
}

import FlowCore
import XCTest

final class ComposeBinderRestrictiveTests: XCTestCase {
    
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
    
    func test_shouldSetFlowStateIsLoadingToTrue_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (sut, _) = makeSUT()
        let flowSpy = ValueSpy(sut.flow.$state)
        
        sut.content.emit(select)
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(isLoading: false, navigation: nil),
            .init(isLoading: true, navigation: nil),
        ])
    }
    
    func test_shouldMessageGetNavigationWithSelect_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (sut, getNavigation) = makeSUT()
        
        sut.content.emit(select)
        
        XCTAssertNoDiff(getNavigation.payloads, [select])
    }
    
    // MARK: - Helpers
    
    private typealias Domain = FlowDomain<Select, Navigation>
    private typealias Content = EmitterReceiver<Select, Void>
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
        let witnesses = content.selectWitnesses()
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
