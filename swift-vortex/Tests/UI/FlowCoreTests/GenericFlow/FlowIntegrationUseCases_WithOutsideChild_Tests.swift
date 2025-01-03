//
//  FlowIntegrationUseCases_WithOutsideChild_Tests.swift
//
//
//  Created by Igor Malyarov on 31.12.2024.
//

import Combine
import CombineSchedulers
import FlowCore
import RxViewModel
import XCTest

final class FlowIntegrationUseCases_WithOutsideChild_Tests: XCTestCase {
    
    func test_shouldNotSetNavigationBeforeChildDelay() {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(1_000))
        
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
    
    func test_shouldSetChildForwardNavigationWithDelay() {
        
        let (sut, spy, scheduler) = makeChild(delay: .milliseconds(777))
        
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
    
    func test_shouldSetChildOutsideNavigationImmediately() {
        
        let (sut, spy, _) = makeChild(delay: .milliseconds(777))
        
        sut.event(.select(.outside(.dismiss)))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .outside(.dismiss)),
        ])
    }
    
    func test_shouldSetParentIsLoadingToTrue_onChildSelect_forward() throws {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(888))
        
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
    
    func test_shouldSetParentIsLoadingToFalse_onChildNavigation_forward_withDelay() throws {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(888))
        
        sut.event(.select(.withOutside))
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(888))
        
        try withOutside(sut).event(.select(.forward))
        
        #warning("why 1ms???")
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            .init(),
            .init(isLoading: true),
            .init(isLoading: false, navigation: .withOutside),
            .init(isLoading: true, navigation: .withOutside),
            .init(isLoading: false, navigation: .withOutside),
        ])
    }
    
    func test_shouldResetParentNavigation_onChildSelectOutsideDismiss_withoutDelay() throws {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(888))
        
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
    
    func test_shouldSetParentIsLoadingFalseNavigationToMain_onChildSelectOutsideMain_withoutDelay() throws {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(888))
        
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
    
    // MARK: - Helpers
    
    private typealias SUT = ParentDomain.Flow
    private typealias State = ParentDomain.FlowDomain.State
    private typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    /// `Parent`
    private func makeSUT(
        initialState: State = .init(),
        childDelay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<EquatableState>,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let composer = ParentComposer(
            childDelay: childDelay,
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
    
    private func makeChild(
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
        case .withOutside: return .withOutside
        }
    }
    
    typealias EquatableState = FlowState<EquatableNavigation>
    
    enum EquatableNavigation: Equatable {
        
        case main, withOutside
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
        
        case main, withOutside
    }
    
    enum Navigation {
        
        case main
        case withOutside(Node<WithOutsideChild>)
    }
    
    typealias WithOutsideChild = WithOutsideChildDomain.Flow
}

private extension ParentDomain.FlowDomain.State {
    
    var withOutside: ParentDomain.WithOutsideChild? {
        
        guard case let .withOutside(node) = navigation else { return nil }
        
        return node.model
    }
}

private final class ParentComposer {
    
    let childDelay: Delay
    let scheduler: AnySchedulerOf<DispatchQueue>
    let navigationScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        childDelay: Delay,
        scheduler: AnySchedulerOf<DispatchQueue>,
        navigationScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.childDelay = childDelay
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
            
        case .withOutside:
            navigationScheduler.delay(for: childDelay) { [weak self] in
                
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
    
    func composeWithOutsideChild() -> Domain.WithOutsideChild {
        
        let composer = WithOutsideChildComposer(
            delay: childDelay,
            scheduler: scheduler,
            navigationScheduler: navigationScheduler
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
