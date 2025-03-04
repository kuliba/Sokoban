//
//  OffsetObservingScrollModelTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 28.02.2025.
//

@testable import Vortex
import Combine
import CombineSchedulers
import XCTest

final class OffsetObservingScrollModelTests: XCTestCase {
    
    func test_noScroll_shouldNotTriggersOnChange() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        scheduler.advance(by: .seconds(2.1))
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    func test_downwardScroll_shouldTriggersOnChange() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut.offset = CGPoint(x: 0, y: 0)
        sut.offset = CGPoint(x: 0, y: -50)
        sut.offset = CGPoint(x: 0, y: -110)
        scheduler.advance(by: .seconds(2.1))
        
        XCTAssertNoDiff(spy.callCount, 1)
    }
    
    func test_upwardScroll_shouldNotTriggerOnChange() {
        
        let (sut, spy, scheduler) = makeSUT()

        
        sut.offset = CGPoint(x: 0, y: 0)
        sut.offset = CGPoint(x: 0, y: 100)

        scheduler.advance(by: .seconds(2.1))

        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_downwardScrollAndUpwardScroll_shouldTriggerOnChangeOnlyOne() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut.offset = CGPoint(x: 0, y: -120)
        scheduler.advance(by: .seconds(2.1))

        XCTAssertNoDiff(spy.callCount, 1)
        
        sut.offset = CGPoint(x: 0, y: 80)
        sut.offset = CGPoint(x: 0, y: 90)
        scheduler.advance(by: .seconds(2.1))

        XCTAssertNoDiff(spy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OffsetObservingScrollModel
    private typealias Spy = CallSpy<Void, Void>
    
    private func makeSUT(
        delay: Delay = .seconds(2),
        threshold: CGFloat = -100,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        
        let scheduler = DispatchQueue.test
        let spy = Spy(stubs: [()])
        let sut = OffsetObservingScrollModel(
            delay: delay,
            threshold: threshold,
            onChange: spy.call,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
}
