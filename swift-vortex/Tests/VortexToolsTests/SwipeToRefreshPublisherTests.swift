//
//  SwipeToRefreshPublisherTests.swift
//
//
//  Created by Igor Malyarov on 01.03.2025.
//

import Combine
import CombineSchedulers
import VortexTools
import XCTest

final class SwipeToRefreshPublisherTests: XCTestCase {
    
    func test_shouldNotTriggerRefresh_onNoOffsetsEmitted() {
        
        let (_, spy, scheduler, cancellable) = makeSUT()
        
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotTriggerRefresh_onSmallOffsetEmitted() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(99)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotTriggerRefresh_onSmallOffsetsEmitted() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(0)
        subject.send(1)
        subject.send(99)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldTriggerRefresh_onSignificantOffsetEmitted() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(101)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldTriggerRefresh_onMaxOffsetExceedsThresholdEvenIfFinalOffsetIsLower() {
        
        let aboveThreshold: CGFloat = 101
        let belowThreshold: CGFloat = 99
        let (subject, spy, scheduler, cancellable) = makeSUT(threshold: 100)
        
        subject.send(aboveThreshold)
        subject.send(belowThreshold)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotTriggerRefresh_onNoOffsetExceedingThreshold() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(99)
        scheduler.advance(by: .seconds(2))

        subject.send(99)
        scheduler.advance(by: .seconds(2))
        
        subject.send(99)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldTriggerRefresh_onExactThreshold() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(100)
        scheduler.advance(by: .seconds(22))
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotTriggerRefresh_onContinuousScrollingWithoutDebounce() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(150)
        subject.send(50)
        
        XCTAssertEqual(spy.callCount, 0)
        
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldTriggerMultipleRefreshes_onSequentialSignificantOffsets() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(150)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 1)
        
        subject.send(120)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 2)
        
        subject.send(110)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 3)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldTriggerMultipleRefreshes_onMixedOffsetsWithSignificant() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT()
        
        subject.send(99)
        subject.send(100)
        subject.send(99)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 1)
        
        subject.send(98)
        subject.send(100)
        subject.send(98)
        scheduler.advance(by: .seconds(2))
        
        XCTAssertEqual(spy.callCount, 2)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldTriggerRefresh_onDebounceCompletionWithMixedOffsets() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT(
            debounceInterval: .milliseconds(100)
        )
        
        subject.send(101) // above
        scheduler.advance(by: .milliseconds(99)) // not yet
        
        XCTAssertEqual(spy.callCount, 0)
        
        subject.send(99) // below
        scheduler.advance(by: .milliseconds(99)) // not yet

        XCTAssertEqual(spy.callCount, 0)

        subject.send(99) // below
        scheduler.advance(by: .milliseconds(99)) // not yet

        XCTAssertEqual(spy.callCount, 0)
        
        scheduler.advance(by: .milliseconds(1)) // go
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldNotTriggerSecondRefresh_onInsignificantOffset() {
        
        let (subject, spy, scheduler, cancellable) = makeSUT(
            debounceInterval: .milliseconds(100)
        )
        
        subject.send(101) // above
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertEqual(spy.callCount, 1)
        
        subject.send(99) // below
        scheduler.advance(by: .milliseconds(100))

        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(cancellable)
    }
    
    // MARK: - Helpers
    
    typealias RefreshSpy = CallSpy<Void, Void>
    
    private func makeSUT(
        threshold: CGFloat = 100.0,
        debounceInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(2),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        subject: PassthroughSubject<CGFloat, Never>,
        spy: RefreshSpy,
        scheduler: TestSchedulerOf<DispatchQueue>,
        cancellable: AnyCancellable
    ) {
        let subject = PassthroughSubject<CGFloat, Never>()
        let spy = RefreshSpy(stubs: .init(repeating: (), count: 100))
        let scheduler = DispatchQueue.test
        let cancellable = subject
            .swipeToRefresh(
                refresh: spy.call,
                config: .init(
                    threshold: threshold,
                    debounce: debounceInterval
                ),
                scheduler: scheduler.eraseToAnyScheduler()
            )
        
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (subject, spy, scheduler, cancellable)
    }
}
