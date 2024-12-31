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
    
    func test_shouldNotSetNavigationBeforeFirstChildDelay() {
        
        let firstChildDelay = makeDelay(ms: 100)
        let (sut, spy, scheduler) = makeSUT(firstChildDelay: firstChildDelay)
        
        sut.event(.select(.first))
        
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
            .init(isLoading: false, navigation: .first),
        ])
    }
    
    func test_shouldNotSetNavigationBeforeSecondChildDelay() {
        
        let secondChildDelay = makeDelay(ms: 1_000)
        let (sut, spy, scheduler) = makeSUT(secondChildDelay: secondChildDelay)
        
        sut.event(.select(.second))
        
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
            .init(isLoading: false, navigation: .second),
        ])
    }
    
    func test_shouldNotSetFirstChildNavigationBeforeDelay() {
        
        let delay = makeDelay(ms: 555)
        let (sut, spy, scheduler) = makeSUT(delay: delay)
        
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
    
    func test_shouldSetParentIsLoadingToTrue_onFirstChildSelect() throws {
        
        let (sut, spy, scheduler) = makeSUT(firstChildDelay: .milliseconds(100))
        
        sut.event(.select(.first))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .first),
        ])
        
        try first(sut).event(.select(.init()))

        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .first),
            .init(isLoading: true, navigation: .first),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ParentDomain.Flow
    private typealias State = ParentDomain.FlowDomain.State
    private typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    /// `Parent`
    private func makeSUT(
        initialState: State = .init(),
        firstChildDelay: Delay = .zero,
        secondChildDelay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<EquatableState>,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let composer = ParentComposer(
            firstChildDelay: firstChildDelay,
            secondChildDelay: secondChildDelay,
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
    
    /// `FirstChild`
    private func makeSUT(
        initialState: FirstChildDomain.FlowDomain.State = .init(),
        delay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: FirstChildDomain.Flow,
        spy: ValueSpy<FirstChildDomain.FlowDomain.State>,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let composer = FirstChildComposer(
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
        case .first:  return .first
        case .second: return .second
        }
    }
    
    typealias EquatableState = FlowState<EquatableNavigation>
    
    enum EquatableNavigation: Equatable {
        
        case first, second
    }
    
    private func first(
        _ sut: SUT
    ) throws -> ParentDomain.FirstChild {
        
        try XCTUnwrap(sut.state.first)
    }
}

// MARK: - Parent

import Combine

#warning("original Node is located in PayHubUI module")
struct Node<Model> {
    
    let model: Model
    private let cancellables: Set<AnyCancellable>
    
    init(
        model: Model,
        cancellables: Set<AnyCancellable>
    ) {
        self.model = model
        self.cancellables = cancellables
    }
    
    init(
        model: Model,
        cancellable: AnyCancellable
    ) {
        self.model = model
        self.cancellables = [cancellable]
    }
}

private enum ParentDomain {
    
    // MARK: - Binder - no Binder
    
    // MARK: - Content - no Content
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case first, second
    }
    
    enum Navigation {
        
        case first(Node<FirstChild>)
        case second
    }
    
    typealias FirstChild = FirstChildDomain.Flow
}

private extension ParentDomain.FlowDomain.State {
    
    var first: ParentDomain.FirstChild? {
    
        guard case let .first(node) = navigation else { return nil }
        
        return node.model
    }
}

private final class ParentComposer {
    
    let firstChildDelay: Delay
    let secondChildDelay: Delay
    let scheduler: AnySchedulerOf<DispatchQueue>
    let navigationScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        firstChildDelay: Delay,
        secondChildDelay: Delay,
        scheduler: AnySchedulerOf<DispatchQueue>,
        navigationScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.firstChildDelay = firstChildDelay
        self.secondChildDelay = secondChildDelay
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
        case .first:
            navigationScheduler.delay(for: firstChildDelay) { //[weak self] in
                #warning("weakify!")
                // guard let self else { return }
                                
                completion(.first(self.composeFirstChildNode(notify)))
            }
            
        case .second:
            navigationScheduler.delay(for: secondChildDelay) {
                
                completion(.second)
            }
        }
    }
    
    func composeFirstChildNode(
        _ notify: @escaping Domain.Notify
    ) -> Node<Domain.FirstChild> {
        
        let composer = FirstChildComposer(
            delay: self.firstChildDelay,
            scheduler: self.scheduler,
            navigationScheduler: self.navigationScheduler
        )
        let first = composer.compose(initialState: .init())
        
        return .init(
            model: first,
            cancellable: first.$state
                .dropFirst()
                .project { _ in nil }
                .sink { notify($0) }
        )
    }
}

private extension AnySchedulerOf<DispatchQueue> {
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: .init(.init(uptimeNanoseconds: 0)).advanced(by: timeout), action)
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}

// MARK: - FirstChild

private enum FirstChildDomain {
    
    // MARK: - Binder - no Binder
    
    // MARK: - Content - no Content
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    struct Select: Equatable {}
    struct Navigation: Equatable {}
}

private final class FirstChildComposer {
    
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

extension FirstChildComposer {
    
    typealias Domain = FirstChildDomain
    
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
