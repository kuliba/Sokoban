//
//  FlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 31.12.2024.
//

import CombineSchedulers
import PayHub
import XCTest

final class FlowIntegrationTests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
        
        let initialState = State(isLoading: true)
        let (_, spy, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [.init(isLoading: true)])
    }
    
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
    
    func test_shouldResetParentNavigation_onWithOutsideChildSelectOutsideDismiss() throws {
        
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
    
    // MARK: - Helpers
    
    private typealias SUT = ParentDomain.Flow
    private typealias State = ParentDomain.FlowDomain.State
    private typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
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
        case .noContent:  return .noContent
        case .withOutside: return .withOutside
        }
    }
    
    typealias EquatableState = FlowState<EquatableNavigation>
    
    enum EquatableNavigation: Equatable {
        
        case noContent, withOutside
    }
    
    private func noContent(
        _ sut: SUT
    ) throws -> ParentDomain.NoContentChild {
        
        try XCTUnwrap(sut.state.noContent)
    }
    
    private func withOutside(
        _ sut: SUT
    ) throws -> ParentDomain.WithOutsideChild {
        
        try XCTUnwrap(sut.state.withOutside)
    }
}

// MARK: - Parent

private enum ParentDomain {
    
    // MARK: - Binder - no Binder
    
    // MARK: - Content - no Content
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case noContent, withOutside
    }
    
    enum Navigation {
        
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
                return nil
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
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
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
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
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
