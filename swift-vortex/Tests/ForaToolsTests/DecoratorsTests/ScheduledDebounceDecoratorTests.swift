//
//  ScheduledDebounceDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import ForaTools
import XCTest

final class ScheduledDebounceDecoratorTests: XCTestCase {
    
    func test_shouldCallOnce() {
        
        let delay = 2.2
        let (sut, scheduler) = makeSUT(delay: delay)
        let exp = expectation(description: "debounce should omit subsequent calls")
        
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        scheduler.advance(by: .seconds(delay + 1))
        
        wait(for: [exp], timeout: delay + 1)
    }
    
    // TODO: not implemented, need to contemplate
//    func test_shouldNotCallOnInstanceDeallocation() {
//        
//        var sut: SUT?
//        let scheduler: TestSchedulerOfDispatchQueue
//        let delay = 2.2
//        (sut, scheduler) = makeSUT(delay: delay)
//        let exp = self.expectation(description: "DebounceDeallocation")
//        exp.isInverted = true
//        
//        sut? { exp.fulfill() }
//        scheduler.advance(by: .seconds(3))
//        sut = nil
//        
//        waitForExpectations(timeout: 0.2) { error in
//            
//            XCTAssertNil(error, "Debounce action was called after instance deallocation")
//        }
//    }
    
    func test_shouldNotCreateRaceCondition() {
        
        let delay = 2.2
        let (sut, scheduler) = makeSUT(delay: delay)
        let exp = expectation(description: "DebounceRace")
        
        let block = { exp.fulfill() }
        
        DispatchQueue.global().async {
            
            sut(block: block)
            scheduler.advance(by: .seconds(delay + 1))
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { [weak sut, weak scheduler] in
            
            sut?(block: block)
            scheduler?.advance(by: .seconds(delay + 1))
        }
        
        waitForExpectations(timeout: delay + 1) { error in
            
            XCTAssertNil(error, "Debounce with race condition test timed out")
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ScheduledDebounceDecorator
    
    private func makeSUT(
        delay: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let sut = SUT(
            delay: delay,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, scheduler)
    }
}
