//
//  FlowIntegrationUseCases_WithContentChild_Tests.swift
//
//
//  Created by Igor Malyarov on 31.12.2024.
//

import Combine
import CombineSchedulers
import FlowCore
import RxViewModel
import XCTest

final class FlowIntegrationUseCases_WithContentChild_Tests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
        
        let initialState = State(isLoading: true)
        let (_, spy, _,_) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [.init(isLoading: true)])
    }
    
    func test_init_shouldNotCallLoad() {
        
        let initialState = State(isLoading: true)
        let (_, _, loadSpy, _) = makeSUT(initialState: initialState)
        
        XCTAssertEqual(loadSpy.callCount, 0)
    }
    
    func test_childContentShouldSetInitialValue() {
        
        let state = WithContentChildContentState(
            isLoading: true,
            value: anyMessage()
        )
        let (_,_, contentSpy, _) = makeChild(initialState: state)
        
        XCTAssertNoDiff(contentSpy.values, [state])
    }
    
    func test_childContentShouldChangeStateOnEvents() {
        
        let (sut, loadSpy, contentSpy, _) = makeChild()
        
        XCTAssertNoDiff(contentSpy.values, [.init()])
        
        sut.content.event(.load)
        
        XCTAssertNoDiff(contentSpy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        let newValue = anyMessage()
        loadSpy.complete(with: newValue)
        
        XCTAssertNoDiff(contentSpy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, value: newValue),
        ])
    }
    
    func test_childFlowShouldChangeStateOnContentEvents() {
        
        let (sut, loadSpy, _, flowSpy) = makeChild()
        
        XCTAssertNoDiff(flowSpy.values, [.init()])
        
        sut.content.event(.load)
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(),
            .init(isLoading: true)
        ])
        
        loadSpy.complete(with: anyMessage())
        
        XCTAssertNoDiff(flowSpy.values, [
            .init(),
            .init(isLoading: true),
            .init(),
        ])
    }
    
    func test_shouldNotSetNavigationBeforeChildDelay() {
        
        let (sut, spy, _, scheduler) = makeSUT(childDelay: .milliseconds(999))
        
        sut.event(.select(.withContent))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(998))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withContent),
        ])
    }
    
    func test_shouldSetParentIsLoadingToTrue_onChildContentLoad() throws {
        
        let (sut, spy, _, scheduler) = makeSUT(childDelay: .milliseconds(999))
        
        sut.event(.select(.withContent))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(999))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withContent),
        ])
        
        try withContent(sut).content.event(.load)
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withContent),
            .init(isLoading: true, navigation: .withContent),
        ])
    }
    
    func test_shouldSetParentIsLoadingToFalse_onChildContentLoaded() throws {
        
        let (sut, spy, loadSpy, scheduler) = makeSUT(childDelay: .milliseconds(999))
        
        sut.event(.select(.withContent))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(999))
        
        try withContent(sut).content.event(.load)
        
        loadSpy.complete(with: anyMessage())
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withContent),
            .init(isLoading: true, navigation: .withContent),
            .init(isLoading: false, navigation: .withContent),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ParentDomain.Flow
    private typealias State = ParentDomain.FlowDomain.State
    private typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    private typealias LoadSpy = Spy<Void, String>
    
    /// `Parent`
    private func makeSUT(
        initialState: State = .init(),
        childDelay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<EquatableState>,
        loadSpy: LoadSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let loadSpy = LoadSpy()
        let scheduler = DispatchQueue.test
        let composer = ParentComposer(
            childDelay: childDelay,
            load: loadSpy.process,
            scheduler: .immediate,
            navigationScheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(initialState: initialState)
        let spy = ValueSpy(sut.$state.map(equatable))
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, loadSpy, scheduler)
    }
    
    private func makeChild(
        initialState: WithContentChildContentState = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: WithContentChildDomain.Binder,
        loadSpy: LoadSpy,
        contentSpy: ValueSpy<WithContentChildContentState>,
        flowSpy: ValueSpy<WithContentChildDomain.FlowDomain.State>
    ) {
        let loadSpy = LoadSpy()
        let contentComposer = WithContentChildDomain.ContentComposer(
            load: loadSpy.process,
            scheduler: .immediate
        )
        let content = contentComposer.compose(initialState: initialState)
        let contentSpy = ValueSpy(content.$state)
        
#warning("looks like bugs in `BinderComposer`: (1) can't compose with Select == Never, (2) `isLoading` is not passed(?)")
        //        let composer = BinderComposer(
        //            getNavigation: getWithContentChildNavigation,
        //            makeContent: { content },
        //            witnesses: .init(
        //                emitting: {
        //
        //                    Empty().eraseToAnyPublisher()
        //                },
        //                dismissing: { _ in {}}
        //            )
        //        )
        //        let sut = composer.compose()
        
        let flowComposer = WithContentChildDomain.FlowDomain.Composer(
            getNavigation: getWithContentChildNavigation,
            scheduler: .immediate
        )
        let flow = flowComposer.compose()
        let flowSpy = ValueSpy(flow.$state)
        
        let sut = WithContentChildDomain.Binder(
            content: content,
            flow: flow,
            bind: { content, flow in
                
                let isLoading = content.$state
                    .map(\.isLoading)
                    .dropFirst()
                    .sink { [weak flow] in flow?.event(.isLoading($0)) }
                
                return [isLoading]
            }
        )
        
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(contentComposer, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(contentSpy, file: file, line: line)
        // trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(flowComposer, file: file, line: line)
        trackForMemoryLeaks(flow, file: file, line: line)
        trackForMemoryLeaks(flowSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loadSpy, contentSpy, flowSpy)
    }
    
    private func getWithContentChildNavigation(
        select: WithContentChildDomain.Select,
        notify: @escaping WithContentChildDomain.Notify,
        completion: @escaping (WithContentChildDomain.Navigation) -> Void
    ) {
        
    }
    
    private func makeDelay(ms milliseconds: Int) -> DispatchQueue.SchedulerTimeType.Stride {
        
        return .milliseconds(milliseconds)
    }
    
    private func equatable(
        _ state: ParentDomain.FlowDomain.State
    ) -> EquatableState {
        
        return .init(
            isLoading: state.isLoading,
            navigation: state.navigation.map(equatable)
        )
    }
    
    private func equatable(
        _ navigation: ParentDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .withContent: return .withContent
        }
    }
    
    typealias EquatableState = FlowState<EquatableNavigation>
    
    enum EquatableNavigation: Equatable {
        
        case main, noContent, withContent, withOutside
    }
    
    private func withContent(
        _ sut: SUT,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ParentDomain.WithContentChild {
        
        try XCTUnwrap(sut.state.withContent, "Expected `WithContentChild`, but got nil instead", file: file, line: line)
    }
}

// MARK: - Parent

private enum ParentDomain {
    
    // MARK: - Binder - no Binder
    
    // MARK: - Content - no Content
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case withContent
    }
    
    enum Navigation {
        
        case withContent(Node<WithContentChild>)
    }
    
    typealias WithContentChild = WithContentChildDomain.Binder
}

private extension ParentDomain.FlowDomain.State {
    
    var withContent: ParentDomain.WithContentChild? {
        
        guard case let .withContent(node) = navigation else { return nil }
        
        return node.model
    }
}

private final class ParentComposer {
    
    let childDelay: Delay
    let load: Load
    let scheduler: AnySchedulerOf<DispatchQueue>
    let navigationScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        childDelay: Delay,
        load: @escaping Load,
        scheduler: AnySchedulerOf<DispatchQueue>,
        navigationScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.childDelay = childDelay
        self.load = load
        self.scheduler = scheduler
        self.navigationScheduler = navigationScheduler
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    typealias Load = (@escaping (String) -> Void) -> Void
}

extension ParentComposer {
    
    typealias Domain = ParentDomain
    
    func compose(
        initialState: Domain.FlowDomain.State
    ) -> Domain.Flow {
        
        let composer = FlowComposer(
            getNavigation: getNavigation,
            scheduler: scheduler
        )
        
        return composer.compose(initialState: initialState)
    }
    
    func getNavigation(
        select: Domain.Select,
        notify: @escaping Domain.Notify,
        completion: @escaping (Domain.Navigation) -> Void
    ) {
        switch select {
        case .withContent:
            navigationScheduler.delay(for: childDelay) { [weak self] in
                
                guard let self else { return }
                
                completion(
                    .withContent(
                        composeWithContentChild()
                            .asNode(
                                transform: { _ in nil },
                                notify: notify
                            )
                    )
                )
            }
        }
    }
    
    func composeWithContentChild() -> Domain.WithContentChild {
        
#warning("extract as Composer")
        let contentComposer = WithContentChildDomain.ContentComposer(
            load: load,
            scheduler: scheduler
        )
        let content = contentComposer.compose()
        
        func getWithContentChildNavigation(
            select: WithContentChildDomain.Select,
            notify: @escaping WithContentChildDomain.Notify,
            completion: @escaping (WithContentChildDomain.Navigation) -> Void
        ) {}
        
        let flowComposer = WithContentChildDomain.FlowDomain.Composer(
            getNavigation: getWithContentChildNavigation,
            scheduler: scheduler
        )
        let flow = flowComposer.compose()
        
        return .init(
            content: content,
            flow: flow,
            bind: { content, flow in
                
                let isLoading = content.$state
                    .map(\.isLoading)
                    .dropFirst()
                    .sink { [weak flow] in flow?.event(.isLoading($0)) }
                
                return [isLoading]
            }
        )
    }
}
    
// MARK: - Helpers

private extension AnySchedulerOf<DispatchQueue> {
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: .init(.init(uptimeNanoseconds: 0)).advanced(by: timeout), action)
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}

// MARK: - WithContentChild

private typealias WithContentChildDomain = BinderDomain<WithContentChildContent, WithContentChildSelect, WithContentChildNavigation>

private extension WithContentChildDomain {
    
    typealias Content = WithContentChildContent
    typealias ContentComposer = WithContentChildContentComposer
    
    typealias Select = WithContentChildSelect
    typealias Navigation = WithContentChildNavigation
}

private typealias WithContentChildContent = RxViewModel<WithContentChildContentState, WithContentChildContentEvent, WithContentChildContentEffect>

private struct WithContentChildContentState: Equatable {
    
    var isLoading = false
    var value: String? = nil
}

private enum WithContentChildContentEvent: Equatable {
    
    case load
    case loaded(String)
}

private enum WithContentChildContentEffect: Equatable {
    
    case load
}

private enum WithContentChildSelect: Equatable {}
private enum WithContentChildNavigation: Equatable {}

private final class WithContentChildContentReducer {}

extension WithContentChildContentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            state.isLoading = true
            effect = .load
            
        case let .loaded(value):
            state.isLoading = false
            state.value = value
        }
        
        return (state, effect)
    }
}

extension WithContentChildContentReducer {
    
    typealias State = WithContentChildContentState
    typealias Event = WithContentChildContentEvent
    typealias Effect = WithContentChildContentEffect
}

private final class WithContentChildContentEffectHandler {
    
    private let load: Load
    
    init(load: @escaping Load) {
        
        self.load = load
    }
    
    typealias Load = (@escaping (String) -> Void) -> Void
}

extension WithContentChildContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            load { dispatch(.loaded($0)) }
        }
    }
}

extension WithContentChildContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = WithContentChildContentEvent
    typealias Effect = WithContentChildContentEffect
}

private final class WithContentChildContentComposer {
    
    private let load: Load
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        load: @escaping Load,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.load = load
        self.scheduler = scheduler
    }
    
    typealias Load = (@escaping (String) -> Void) -> Void
}

extension WithContentChildContentComposer {
    
    func compose(
        initialState: WithContentChildContentState = .init()
    ) -> WithContentChildDomain.Content {
        
        let reducer = WithContentChildContentReducer()
        let effectHandler = WithContentChildContentEffectHandler(load: load)
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
