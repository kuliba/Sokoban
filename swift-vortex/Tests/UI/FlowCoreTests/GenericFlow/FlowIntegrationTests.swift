//
//  FlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 31.12.2024.
//

import CombineSchedulers
import FlowCore
import RxViewModel
import XCTest

final class FlowIntegrationTests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
        
        let initialState = State(isLoading: true)
        let (_, spy, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [.init(isLoading: true)])
    }
    
    // MARK: - NoContentChild
    
    func test_shouldNotSetNavigationBeforeNoContentChildDelay() {
        
        let noContentChildDelay = makeDelay(ms: 100)
        let (sut, spy, scheduler) = makeSUT(noContentChildDelay: noContentChildDelay)
        
        sut.event(.select(.noContent))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(99))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .noContent),
        ])
    }
    
    func test_shouldNotSetNoContentChildNavigationBeforeDelay() {
        
        let delay = makeDelay(ms: 555)
        let (sut, spy, scheduler) = makeNoContentChild(delay: delay)
        
        sut.event(.select(.init()))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(554))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .init()),
        ])
    }
    
    func test_shouldSetParentIsLoadingToTrue_onNoContentChildSelect() throws {
        
        let (sut, spy, scheduler) = makeSUT(noContentChildDelay: .milliseconds(100))
        
        sut.event(.select(.noContent))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .noContent),
        ])
        
        try noContent(sut).event(.select(.init()))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .noContent),
            .init(isLoading: true, navigation: .noContent),
        ])
    }
    
    func test_shouldSetParentIsLoadingToFalse_onNoContentChildNavigation() throws {
        
        let (sut, spy, scheduler) = makeSUT(noContentChildDelay: .milliseconds(100))
        
        sut.event(.select(.noContent))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        try noContent(sut).event(.select(.init()))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .noContent),
            .init(isLoading: true, navigation: .noContent),
        ])
        
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .noContent),
            .init(isLoading: true, navigation: .noContent),
            .init(isLoading: false, navigation: .noContent),
        ])
    }
    
    // MARK: - WithOutsideChild
    
    func test_shouldNotSetNavigationBeforeWithOutsideChildDelay() {
        
        let withOutsideChildDelay = makeDelay(ms: 1_000)
        let (sut, spy, scheduler) = makeSUT(withOutsideChildDelay: withOutsideChildDelay)
        
        sut.event(.select(.withOutside))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(999))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
        ])
    }
    
    func test_shouldSetWithOutsideChildForwardNavigationWithDelay() {
        
        let (sut, spy, scheduler) = makeWithOutsideChild(delay: .milliseconds(777))
        
        sut.event(.select(.forward))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(776))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .forward),
        ])
    }
    
    func test_shouldSetWithOutsideChildOutsideNavigationImmediately() {
        
        let (sut, spy, _) = makeWithOutsideChild(delay: .milliseconds(777))
        
        sut.event(.select(.outside(.dismiss)))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .outside(.dismiss)),
        ])
    }
    
    func test_shouldSetParentIsLoadingToTrue_onWithOutsideChildSelect_forward() throws {
        
        let (sut, spy, scheduler) = makeSUT(withOutsideChildDelay: .milliseconds(888))
        
        sut.event(.select(.withOutside))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(888))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
        ])
        
        try withOutside(sut).event(.select(.forward))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
            .init(isLoading: true, navigation: .withOutside),
        ])
    }
    
    func test_shouldSetParentIsLoadingToFalse_onWithOutsideChildNavigation_forward_withDelay() throws {
        
        let (sut, spy, scheduler) = makeSUT(withOutsideChildDelay: .milliseconds(888))
        
        sut.event(.select(.withOutside))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(888))
        
        try withOutside(sut).event(.select(.forward))
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
            .init(isLoading: true, navigation: .withOutside),
            .init(isLoading: false, navigation: .withOutside),
        ])
    }
    
    func test_shouldResetParentNavigation_onWithOutsideChildSelectOutsideDismiss_withoutDelay() throws {
        
        let (sut, spy, scheduler) = makeSUT(withOutsideChildDelay: .milliseconds(888))
        
        sut.event(.select(.withOutside))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(888))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
        ])
        
        try withOutside(sut).event(.select(.outside(.dismiss)))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
            .init(isLoading: true, navigation: .withOutside),
            .init(isLoading: false, navigation: nil),
        ])
    }
    
    func test_shouldSetParentIsLoadingFalseNavigationToMain_onWithOutsideChildSelectOutsideMain_withoutDelay() throws {
        
        let (sut, spy, scheduler) = makeSUT(withOutsideChildDelay: .milliseconds(888))
        
        sut.event(.select(.withOutside))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(888))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
        ])
        
        try withOutside(sut).event(.select(.outside(.main)))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
            .init(isLoading: true, navigation: .withOutside),
            .init(isLoading: true, navigation: nil),
            .init(isLoading: false, navigation: .main),
        ])
    }
    
    // MARK: - WithContentChild
    
    func test_withContentChildContentShouldSetInitialValue() {
        
        let initialState = WithContentChildContentState(
            isLoading: true,
            value: anyMessage()
        )
        let (_,_, spy) = makeWithContentChildContent(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    func test_withContentChildContentShouldChangeStateOnEvents() {
        
        let (sut, loadSpy, spy) = makeWithContentChildContent()
        
        XCTAssertNoDiff(spy.values, [.init()])
        
        sut.event(.load)
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        let newValue = anyMessage()
        loadSpy.complete(with: newValue)
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, value: newValue),
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
        noContentChildDelay: Delay = .zero,
        withOutsideChildDelay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<EquatableState>,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let composer = ParentComposer(
            noContentChildDelay: noContentChildDelay,
            withOutsideChildDelay: withOutsideChildDelay,
            scheduler: .immediate,
            navigationScheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(initialState: initialState)
        let spy = ValueSpy(sut.$state.map(equatable))
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func makeNoContentChild(
        initialState: NoContentChildDomain.FlowDomain.State = .init(),
        delay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: NoContentChildDomain.Flow,
        spy: ValueSpy<NoContentChildDomain.FlowDomain.State>,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let composer = NoContentChildComposer(
            delay: delay,
            scheduler: .immediate,
            navigationScheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(initialState: initialState)
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func makeWithOutsideChild(
        initialState: WithOutsideChildDomain.FlowDomain.State = .init(),
        delay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: WithOutsideChildDomain.Flow,
        spy: ValueSpy<WithOutsideChildDomain.FlowDomain.State>,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let composer = WithOutsideChildComposer(
            delay: delay,
            scheduler: .immediate,
            navigationScheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(initialState: initialState)
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func makeWithContentChildContent(
        initialState: WithContentChildContentState = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: WithContentChildContent,
        loadSpy: LoadSpy,
        spy: ValueSpy<WithContentChildContentState>
    ) {
        let loadSpy = LoadSpy()
        let composer = WithContentChildDomain.ContentComposer(
            load: loadSpy.process,
            scheduler: .immediate
        )
        let sut = composer.compose(initialState: initialState)
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, loadSpy, spy)
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
        case .main:        return .main
        case .noContent:   return .noContent
        case .withOutside: return .withOutside
        }
    }
    
    typealias EquatableState = FlowState<EquatableNavigation>
    
    enum EquatableNavigation: Equatable {
        
        case main, noContent, withOutside
    }
    
    private func noContent(
        _ sut: SUT,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ParentDomain.NoContentChild {
        
        try XCTUnwrap(sut.state.noContent, "Expected `NoContentChild`, but got nil instead", file: file, line: line)
    }
    
    private func withOutside(
        _ sut: SUT,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ParentDomain.WithOutsideChild {
        
        try XCTUnwrap(sut.state.withOutside, "Expected `WithOutsideChild`, but got nil instead", file: file, line: line)
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
        
        case main, noContent, withOutside
    }
    
    enum Navigation {
        
        case main
        case noContent(Node<NoContentChild>)
        case withOutside(Node<WithOutsideChild>)
    }
    
    typealias NoContentChild = NoContentChildDomain.Flow
    typealias WithOutsideChild = WithOutsideChildDomain.Flow
}

private extension ParentDomain.FlowDomain.State {
    
    var noContent: ParentDomain.NoContentChild? {
        
        guard case let .noContent(node) = navigation else { return nil }
        
        return node.model
    }
    
    var withOutside: ParentDomain.WithOutsideChild? {
        
        guard case let .withOutside(node) = navigation else { return nil }
        
        return node.model
    }
}

private final class ParentComposer {
    
    let noContentChildDelay: Delay
    let withOutsideChildDelay: Delay
    let scheduler: AnySchedulerOf<DispatchQueue>
    let navigationScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        noContentChildDelay: Delay,
        withOutsideChildDelay: Delay,
        scheduler: AnySchedulerOf<DispatchQueue>,
        navigationScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.noContentChildDelay = noContentChildDelay
        self.withOutsideChildDelay = withOutsideChildDelay
        self.scheduler = scheduler
        self.navigationScheduler = navigationScheduler
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
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
        case .main:
            completion(.main)
            
        case .noContent:
            navigationScheduler.delay(for: noContentChildDelay) { [weak self] in
                
                guard let self else { return }
                
                completion(.noContent(
                    composeNoContentChild()
                        .asNode(
                            transform: { _ in nil },
                            notify: notify
                        )
                ))
            }
            
        case .withOutside:
            navigationScheduler.delay(for: withOutsideChildDelay) { [weak self] in
                
                guard let self else { return }
                
                completion(.withOutside(
                    composeWithOutsideChild()
                        .asNode(
                            transform: { $0.outcome },
                            notify: notify
                        )
                ))
            }
        }
    }
    
    func composeNoContentChild() -> Domain.NoContentChild {
        
        let composer = NoContentChildComposer(
            delay: self.noContentChildDelay,
            scheduler: self.scheduler,
            navigationScheduler: self.navigationScheduler
        )
        
        return composer.compose(initialState: .init())
    }
    
    func composeWithOutsideChild() -> Domain.WithOutsideChild {
        
        let composer = WithOutsideChildComposer(
            delay: self.noContentChildDelay,
            scheduler: self.scheduler,
            navigationScheduler: self.navigationScheduler
        )
        
        return composer.compose(initialState: .init())
    }
}

// MARK: - Adapters

private extension WithOutsideChildDomain.Navigation {
    
    var outcome: NavigationOutcome<ParentDomain.Select>? {
        
        switch self {
        case .forward:
            return nil
            
        case let .outside(outside):
            switch outside {
            case .dismiss:
                return .dismiss
                
            case .main:
                return .select(.main)
            }
        }
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

// MARK: - NoContentChild

private enum NoContentChildDomain {
    
    // MARK: - Binder - no Binder
    
    // MARK: - Content - no Content
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    struct Select: Equatable {}
    struct Navigation: Equatable {}
}

private final class NoContentChildComposer {
    
    let delay: Delay
    let scheduler: AnySchedulerOf<DispatchQueue>
    let navigationScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        delay: Delay,
        scheduler: AnySchedulerOf<DispatchQueue>,
        navigationScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.scheduler = scheduler
        self.navigationScheduler = navigationScheduler
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}

extension NoContentChildComposer {
    
    typealias Domain = NoContentChildDomain
    
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
        navigationScheduler.delay(for: delay) {
            
            completion(.init())
        }
    }
}

// MARK: - WithOutsideChild

private enum WithOutsideChildDomain {
    
    // MARK: - Binder - no Binder
    
    // MARK: - Content - no Content
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable {
        
        case forward
        case outside(Outside)
    }
    
    typealias Navigation = Select
    
    enum Outside: Equatable {
        
        case dismiss, main
    }
}

private final class WithOutsideChildComposer {
    
    let delay: Delay
    let scheduler: AnySchedulerOf<DispatchQueue>
    let navigationScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        delay: Delay,
        scheduler: AnySchedulerOf<DispatchQueue>,
        navigationScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.scheduler = scheduler
        self.navigationScheduler = navigationScheduler
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}

extension WithOutsideChildComposer {
    
    typealias Domain = WithOutsideChildDomain
    
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
        case .forward:
            navigationScheduler.delay(for: delay) {
                
                completion(.forward)
            }
            
        case let .outside(outside):
            completion(.outside(outside))
        }
    }
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
