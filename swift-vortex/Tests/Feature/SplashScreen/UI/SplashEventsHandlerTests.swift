//
//  SplashEventsHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2025.
//

import Combine
import CombineSchedulers
import SplashScreenUI
import XCTest

final class SplashEventsHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, _,_, spy, _) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_bind_shouldDeliverPrepareEvent_onAuthOK() {
        
        let (sut, authOK, _, spy, scheduler) = makeSUT()
        let cancellables = bind(sut, on: scheduler)
        
        authOK.send(())
        
        XCTAssertNoDiff(spy.payloads, [.prepare])
        XCTAssertNotNil(cancellables)
    }
    
    func test_bind_shouldDeliverStartEventImmediatelyAndHideEventAfterDelay_onStart() {
        
        let (sut, _, start, spy, scheduler) = makeSUT()
        let cancellables = bind(sut, with: .milliseconds(100), on: scheduler)
        
        start.send(())
        XCTAssertNoDiff(spy.payloads, [.start])
        
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(spy.payloads, [.start, .hide])
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SplashEventsHandler
    typealias Event = SplashScreenEvent
    private typealias EventSpy = CallSpy<Event, Void>
    private typealias Subject = PassthroughSubject<Void, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        authOK: Subject,
        start: Subject,
        spy: EventSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let authOK = Subject()
        let start = Subject()
        let spy = EventSpy(stubs: .init(repeating: (), count: 9))
        let sut = SUT(
            authOKPublisher: authOK.eraseToAnyPublisher(),
            startPublisher: start.eraseToAnyPublisher(),
            event: spy.call
        )
        let scheduler = DispatchQueue.test
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(authOK, file: file, line: line)
        trackForMemoryLeaks(start, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, authOK, start, spy, scheduler)
    }
    
    private func bind(
        _ sut: SUT,
        with delay: SUT.Delay = .seconds(1),
        on scheduler: TestSchedulerOf<DispatchQueue>
    ) -> Set<AnyCancellable> {
        
        return sut.bind(delay: delay, on: scheduler.eraseToAnyScheduler())
    }
}
