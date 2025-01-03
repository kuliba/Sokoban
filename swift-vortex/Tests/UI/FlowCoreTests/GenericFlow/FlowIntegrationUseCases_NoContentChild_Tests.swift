//
//  FlowIntegrationUseCases_NoContentChild_Tests.swift
//
//
//  Created by Igor Malyarov on 31.12.2024.
//

import Combine
import CombineSchedulers
import FlowCore
import RxViewModel
import XCTest

final class FlowIntegrationUseCases_NoContentChild_Tests: XCTestCase {
    
    func test_shouldNotSetNavigationBeforeChildDelay() {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(100))
        
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
    
    func test_shouldNotSetChildNavigationBeforeDelay() {
        
        let (sut, spy, scheduler) = makeChild(delay: .milliseconds(555))
        
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
    
    func test_shouldSetParentIsLoadingToTrue_onChildSelect() throws {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(100))
        
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
    
    func test_shouldSetParentIsLoadingToFalse_onChildNavigation() throws {
        
        let (sut, spy, scheduler) = makeSUT(childDelay: .milliseconds(100))
        
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
        case .noContent:   return .noContent
        }
    }
    
    typealias EquatableState = FlowState<EquatableNavigation>
    
    enum EquatableNavigation: Equatable {
        
        case main, noContent, withContent, withOutside
    }
    
    private func noContent(
        _ sut: SUT,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ParentDomain.NoContentChild {
        
        try XCTUnwrap(sut.state.noContent, "Expected `NoContentChild`, but got nil instead", file: file, line: line)
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
        
        case noContent
    }
    
    enum Navigation {
        
        case noContent(Node<NoContentChild>)
    }
    
    typealias NoContentChild = NoContentChildDomain.Flow
}

private extension ParentDomain.FlowDomain.State {
    
    var noContent: ParentDomain.NoContentChild? {
        
        guard case let .noContent(node) = navigation else { return nil }
        
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
        case .noContent:
            navigationScheduler.delay(for: childDelay) { [weak self] in
                
                guard let self else { return }
                
                completion(.noContent(
                    composeChild()
                        .asNode(
                            transform: { _ in nil },
                            notify: notify
                        )
                ))
            }
        }
    }
    
    func composeChild() -> Domain.NoContentChild {
        
        let composer = NoContentChildComposer(
            delay: childDelay,
            scheduler: scheduler,
            navigationScheduler: navigationScheduler
        )
        
        return composer.compose(initialState: .init())
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
