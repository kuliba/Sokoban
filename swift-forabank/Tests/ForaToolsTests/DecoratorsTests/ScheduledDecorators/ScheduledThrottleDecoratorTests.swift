//
//  ScheduledThrottleDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import ForaTools
import XCTest

final class ScheduledThrottleDecoratorTests: XCTestCase {
    
    func test_shouldNotThrottleForZeroDelay() {
        
        let (sut, scheduler) = makeSUT(timeInterval: .zero)
        let exp = expectation(description: "Should not throttle execution with zero delay.")
        exp.expectedFulfillmentCount = 2
        
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        
        scheduler.advance()
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_shouldNotExecuteOnIdleSchedulerForZeroDelay() {
        
        let (sut, _) = makeSUT(timeInterval: .zero)
        let exp = expectation(description: "Should not throttle execution with zero delay.")
        exp.expectedFulfillmentCount = 2
        exp.isInverted = true
        
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_shouldExecuteFirstCall() {
        
        let (sut, scheduler) = makeSUT()
        let exp = expectation(description: "Throttle executes immediately at first call.")
        
        sut { exp.fulfill() }
        
        scheduler.advance()
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_shouldIgnoreImmediateSubsequentCall() {
        
        let (sut, scheduler) = makeSUT()
        let exp = expectation(description: "Only the first call should be executed")
        
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        
        scheduler.advance()
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_shouldExecuteOnBackgroundThread() {
        
        let (sut, scheduler) = makeSUT()
        let exp = expectation(description: "Execute on background thread")
        
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        backgroundQueue.async {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }
        
        wait(for: [exp], timeout: 0.2)
    }
    
    func test_shouldNotCrashOnDifferentQueues_threadSafety() {
        
        let delay = 0.1
        let (sut, scheduler) = makeSUT()
        let exp = expectation(description: "Complete multiple concurrent calls")
        exp.expectedFulfillmentCount = 2
        
        let concurrentQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        for _ in 0..<100 {
            
            concurrentQueue.async {
                
                sut { exp.fulfill() }
                scheduler.advance()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.1) {
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDelayReExecution() {
        
        let delay = 0.1
        let (sut, scheduler) = makeSUT(timeInterval: delay)
        let exp = expectation(description: "Throttle re-executes after specified delay")
        exp.expectedFulfillmentCount = 2
        
        for _ in 1...10 {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldExecuteLongDelay() {
        
        let delay = 0.5
        let (sut, scheduler) = makeSUT(timeInterval: delay)
        let exp = expectation(description: "Throttle works correctly with long delays")
        exp.expectedFulfillmentCount = 2
        
        for _ in 1...10 {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            for _ in 1...10 {
                
                sut { exp.fulfill() }
                scheduler.advance()
            }
        }
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_shouldIgnoreCallJustBeforeThrottleExpiration() {
        
        let delay = 0.1
        let (sut, scheduler) = makeSUT(timeInterval: delay)
        let exp = expectation(description: "Throttle should handle calls with varying intervals")
        exp.expectedFulfillmentCount = 2

        sut { exp.fulfill() }
        scheduler.advance()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 0.9) {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 1.1) {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }

        wait(for: [exp], timeout: 0.5)
    }

    func test_shouldExecuteCallAtExpiration() {
        
        let delay = 0.1
        let (sut, scheduler) = makeSUT(timeInterval: delay)
        let exp = expectation(description: "Throttle should only allow re-execution right at boundary expiration")
        exp.expectedFulfillmentCount = 2

        sut { exp.fulfill() }
        scheduler.advance()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }

        wait(for: [exp], timeout: 0.3)
    }

    func test_shouldExecuteDifferentBlocks() {
        
        let delay = 0.1
        let (sut, scheduler) = makeSUT(timeInterval: delay)
        let exp = expectation(description: "Throttle executes different blocks correctly")
        exp.expectedFulfillmentCount = 2
        var executionFlag = false
        
        sut {
            
            executionFlag = true
            exp.fulfill()
        }
        scheduler.advance()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            sut { exp.fulfill() }
            scheduler.advance()
        }
        
        wait(for: [exp], timeout: 0.2)
        XCTAssertTrue(executionFlag, "Initial block should have been executed")
    }
    
    func test_shouldNotHaveRaceConditionWithConcurrentAccess() {
        
        let delay = 0.1
        let (sut, scheduler) = makeSUT(timeInterval: delay)
        let exp = expectation(description: "Complete multiple concurrent calls")
        exp.expectedFulfillmentCount = 2
        
        let concurrentQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        sut { exp.fulfill() }
        scheduler.advance()
        
        for _ in 0..<10 {
            
            concurrentQueue.asyncAfter(deadline: .now() + delay) {
                
                sut { exp.fulfill() }
                scheduler.advance()
            }
        }
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ScheduledThrottleDecorator
    
    private func makeSUT(
        timeInterval: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let sut = SUT(
            timeInterval: timeInterval,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, scheduler)
    }
}
