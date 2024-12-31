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
        
        let initialState = makeState(isLoading: true)
        let (_, spy, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    func test_shouldNotSetNavigationBeforeFirstChildDelay() {
        
        let firstChildDelay = makeDelay(ms: 100)
        let (sut, spy, scheduler) = makeSUT(firstChildDelay: firstChildDelay)
        
        sut.event(.select(.first))
        
        XCTAssertNoDiff(spy.values, [
            makeState(),
            makeState(isLoading: true),
        ])
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(99))
        
        XCTAssertNoDiff(spy.values, [
            makeState(),
            makeState(isLoading: true),
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            makeState(),
            makeState(isLoading: true),
            makeState(isLoading: false, navigation: .first),
        ])
    }
    
    func test_shouldNotSetNavigationBeforeSecondChildDelay() {
        
        let secondChildDelay = makeDelay(ms: 1_000)
        let (sut, spy, scheduler) = makeSUT(secondChildDelay: secondChildDelay)
        
        sut.event(.select(.second))
        
        XCTAssertNoDiff(spy.values, [
            makeState(),
            makeState(isLoading: true),
        ])
        
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(999))
        
        XCTAssertNoDiff(spy.values, [
            makeState(),
            makeState(isLoading: true),
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            makeState(),
            makeState(isLoading: true),
            makeState(isLoading: false, navigation: .second),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ParentDomain.Flow
    private typealias State = ParentDomain.FlowDomain.State
    private typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    private func makeSUT(
        initialState: State = .init(),
        firstChildDelay: Delay = .zero,
        secondChildDelay: Delay = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<State>,
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
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private func makeState(
        isLoading: Bool = false,
        navigation: ParentDomain.Navigation? = nil
    ) -> State {
        
        return .init(isLoading: isLoading, navigation: navigation)
    }
    
    private func makeDelay(ms milliseconds: Int) -> DispatchQueue.SchedulerTimeType.Stride {
        
        return .milliseconds(milliseconds)
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
    
    enum Navigation: Equatable {
        
        case first, second
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
    
    func compose(
        initialState: ParentDomain.FlowDomain.State
    ) -> ParentDomain.Flow {
        
        let composer = FlowComposer(
            getNavigation: getNavigation,
            scheduler: scheduler
        )
        
        return composer.compose(initialState: initialState)
    }
    
    func getNavigation(
        select: ParentDomain.Select,
        notify: @escaping ParentDomain.Notify,
        completion: @escaping (ParentDomain.Navigation) -> Void
    ) {
        switch select {
        case .first:
            navigationScheduler.delay(for: firstChildDelay) {
                
                completion(.first)
            }
        case .second:
            navigationScheduler.delay(for: secondChildDelay) {
                
                completion(.second)
            }
        }
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
