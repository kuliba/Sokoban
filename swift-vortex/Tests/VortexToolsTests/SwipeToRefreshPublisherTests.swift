//
//  SwipeToRefreshPublisherTests.swift
//
//
//  Created by Igor Malyarov on 01.03.2025.
//

import Combine
import CombineSchedulers

/// Configuration parameters for the refresh pipeline.
struct SwipeToRefreshConfig {
    
    /// Minimum offset required to trigger refresh.
    let threshold: CGFloat
    /// Debounce interval (the period during which offset events are collected).
    let debounceInterval: DispatchQueue.SchedulerTimeType.Stride
}

extension Publisher where Output == CGFloat, Failure == Never {
    
    /// Collects offset events over the specified debounce interval and, if the maximum offset in that
    /// window is at or above the configured threshold, calls the refresh closure. The collection resets
    /// automatically between debounce windows so that subsequent valid pulls can trigger refresh again.
    ///
    /// - Parameters:
    ///   - refresh: The closure to call when a valid pull-to-refresh gesture is detected.
    ///   - config: The refresh configuration containing the threshold and debounce interval.
    ///   - scheduler: The scheduler used to drive the debounce timer.
    /// - Returns: An `AnyCancellable` that must be retained to keep the subscription active.
    func swipeToRefresh(
        refresh: @escaping () -> Void,
        config: SwipeToRefreshConfig,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> AnyCancellable {
        
        return self
        // Collect all offset events that occur during the debounce interval.
            .collect(.byTime(scheduler, config.debounceInterval))
        // Proceed only if the collected array is non-empty and the maximum offset is at or above the threshold.
            .filter { ($0.max() ?? 0) >= config.threshold }
        // When the condition is met, trigger the refresh closure.
            .sink { _ in refresh() }
    }
}

import Combine
import CombineSchedulers
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
                    debounceInterval: debounceInterval
                ),
                scheduler: scheduler.eraseToAnyScheduler()
            )
        
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (subject, spy, scheduler, cancellable)
    }
}
