//
//  AnySchedulerOf+decorateGetNavigationTests.swift
//
//
//  Created by Igor Malyarov on 05.01.2025.
//

import CombineSchedulers
import FlowCore
import XCTest

final class AnySchedulerOf_decorateGetNavigationTests: XCTestCase {
    
    func test_shouldCallOriginalGetNavigationWithSelect() {
        
        let select = makeSelect()
        let (sut, getNavigation, _,_) = makeSUT()
        
        sut(select, { _ in }, { _ in })
        
        XCTAssertNoDiff(getNavigation.payloads.map(\.0), [select])
    }
    
    func test_shouldCallOriginalGetNavigationWithNotify() throws {
        
        let select = makeSelect()
        let notifySpy = NotifySpy(stubs: [()])
        let (sut, getNavigation, _,_) = makeSUT()
        
        sut(makeSelect(), notifySpy.call, { _ in })
        let notify = try XCTUnwrap(getNavigation.payloads.first).1
        notify(.select(select))
        
        XCTAssertNoDiff(notifySpy.payloads, [.select(select)])
    }
    
    func test_shouldCallDelayProviderWithNavigation() {
        
        let navigation = makeNavigation()
        let (sut, getNavigation, delaySpy, _) = makeSUT(delays: .milliseconds(777))
        
        sut(makeSelect(), { _ in }, { _ in })
        getNavigation.complete(with: navigation)
        
        XCTAssertNoDiff(delaySpy.payloads, [navigation])
    }
    
    func test_shouldCompleteWithDelay() {
        
        let navigation = makeNavigation()
        let (sut, getNavigation, _, scheduler) = makeSUT(delays: .milliseconds(777))
        var navigations = [Navigation]()
        
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        getNavigation.complete(with: navigation)
        
        XCTAssertNoDiff(navigations, [])
        
        scheduler.advance(to: scheduler.now)
        scheduler.advance(by: .milliseconds(776))
        
        XCTAssertNoDiff(navigations, [])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(navigations, [navigation])
    }
    
    func test_shouldCompleteImmediatelyWithZeroDelay() {
        
        let navigation = makeNavigation()
        let (sut, getNavigation, _,_) = makeSUT(delays: .zero)
        var navigations = [Navigation]()
        
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        getNavigation.complete(with: navigation)
        
        XCTAssertNoDiff(navigations, [navigation])
    }
    
    func test_shouldCompleteImmediatelyWithNegativeDelay() {
        
        let navigation = makeNavigation()
        let (sut, getNavigation, _,_) = makeSUT(delays: -.seconds(500))
        var navigations = [Navigation]()
        
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        getNavigation.complete(with: navigation)
        
        XCTAssertNoDiff(navigations, [navigation])
    }
    
    func test_shouldHandleMultipleNavigationsWithCorrespondingDelays() {
        
        let navigation1 = makeNavigation()
        let navigation2 = makeNavigation()
        let (sut, getNavigation, _, scheduler) = makeSUT(
            delays: .milliseconds(500), .milliseconds(100)
        )
        var navigations = [Navigation]()
        
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        
        getNavigation.complete(with: navigation1)
        scheduler.advance(by: .milliseconds(499))
        XCTAssertNoDiff(navigations, [])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(navigations, [navigation1])
        
        getNavigation.complete(with: navigation2, at: 1)
        scheduler.advance(by: .milliseconds(99))
        XCTAssertNoDiff(navigations, [navigation1])

        scheduler.advance(by: .milliseconds(99))
        XCTAssertNoDiff(navigations, [navigation1, navigation2])
    }
    
    func test_shouldHandleMultipleNavigationsWithZeroDelays() {
        
        let navigation1 = makeNavigation()
        let navigation2 = makeNavigation()
        let (sut, getNavigation, _,_) = makeSUT(delays: .zero, .zero)
        var navigations = [Navigation]()
        
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        
        getNavigation.complete(with: navigation1)
        getNavigation.complete(with: navigation2, at: 1)
        
        XCTAssertNoDiff(navigations, [navigation1, navigation2])
    }
    
    func test_shouldHandleLargeDelayGracefully() {
        
        let navigation = makeNavigation()
        let largeDelay: Delay = .seconds(60*60*24*30)
        let (sut, getNavigation, _, scheduler) = makeSUT(delays: largeDelay)
        var navigations = [Navigation]()
        
        sut(makeSelect(), { _ in }) { navigations.append($0) }
        getNavigation.complete(with: navigation)
        
        scheduler.advance(by: largeDelay)
        XCTAssertNoDiff(navigations, [navigation])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Domain.GetNavigation
    private typealias Domain = FlowDomain<Select, Navigation>
    private typealias GetNavigationSpy = Spy<(Select, Domain.Notify), Navigation>
    private typealias Delay = AnySchedulerOf<DispatchQueue>.Delay
    private typealias DelaySpy = CallSpy<Navigation, Delay>
    private typealias NotifySpy = CallSpy<Domain.NotifyEvent, Void>
    
    private func makeSUT(
        delays: Delay...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getNavigation: GetNavigationSpy,
        delaySpy: DelaySpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let getNavigation = GetNavigationSpy()
        let delaySpy = DelaySpy(stubs: delays)
        let scheduler = DispatchQueue.test
        let decorate: (@escaping SUT) -> SUT = scheduler
            .eraseToAnyScheduler()
            .decorateGetNavigation(delayProvider: delaySpy.call)
        let decorated = decorate(getNavigation.process(_:_:completion:))
        
        trackForMemoryLeaks(getNavigation, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (decorated, getNavigation, delaySpy, scheduler)
    }
    
    private struct Select: Equatable {
        
        let value: String
    }
    
    private func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
    
    private struct Navigation: Equatable {
        
        let value: String
    }
    
    private func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
}
