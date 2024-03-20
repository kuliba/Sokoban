//
//  ThrottleDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import ForaTools
import XCTest

final class ThrottleDecoratorTests: XCTestCase {
    
    func test_shouldNotThrottleForZeroDelay() {
        
        let sut = makeSUT(delay: .zero)
        let exp = expectation(description: "Should not throttle execution with zero delay.")
        exp.expectedFulfillmentCount = 2
        
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_shouldExecuteFirstCall() {
        
        let sut = makeSUT()
        let exp = expectation(description: "Throttle executes immediately at first call.")
        
        sut { exp.fulfill() }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_shouldIgnoreImmediateSubsequentCall() {
        
        let sut = makeSUT(delay: 0.5)
        let exp = expectation(description: "Only the first call should be executed")
        
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_shouldExecuteOnBackgroundThread() {
        
        let sut = makeSUT()
        let exp = expectation(description: "Execute on background thread")
        
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        backgroundQueue.async {
            
            sut { exp.fulfill() }
        }
        
        wait(for: [exp], timeout: 0.2)
    }
    
    func test_shouldBotCrashOnDifferentQueues_threadSafety() {
        
        let delay = 0.1
        let sut = makeSUT()
        let exp = expectation(description: "Complete multiple concurrent calls")
        exp.expectedFulfillmentCount = 2
        
        let concurrentQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        for _ in 0..<100 {
            
            concurrentQueue.async {
                
                sut { exp.fulfill() }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.1) {
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDelayReExecution() {
        
        let delay = 0.1
        let sut = makeSUT(delay: delay)
        let exp = expectation(description: "Throttle re-executes after specified delay")
        exp.expectedFulfillmentCount = 2
        
        for _ in 1...10 {
            
            sut { exp.fulfill() }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            sut { exp.fulfill() }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldExecuteLongDelay() {
        
        let delay = 0.5
        let sut = makeSUT(delay: delay)
        let exp = expectation(description: "Throttle works correctly with long delays")
        exp.expectedFulfillmentCount = 2
        
        for _ in 1...10 {
            
            sut { exp.fulfill() }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            for _ in 1...10 {
                
                sut { exp.fulfill() }
            }
        }
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_shouldExecuteDifferentBlocks() {
        
        let delay = 0.1
        let sut = makeSUT(delay: delay)
        let exp = expectation(description: "Throttle executes different blocks correctly")
        exp.expectedFulfillmentCount = 2
        var executionFlag = false
        
        sut {
            
            executionFlag = true
            exp.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            sut { exp.fulfill() }
        }
        
        wait(for: [exp], timeout: 0.2)
        XCTAssertTrue(executionFlag, "Initial block should have been executed")
    }
    
    func test_shouldNotHaveRaceConditionWithConcurrentAccess() {
        
        let delay = 0.1
        let sut = makeSUT(delay: delay)
        let exp = expectation(description: "Complete multiple concurrent calls")
        exp.expectedFulfillmentCount = 2
        
        let concurrentQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        sut { exp.fulfill() }
        
        for _ in 0..<10 {
            
            concurrentQueue.asyncAfter(deadline: .now() + delay) {
                
                sut { exp.fulfill() }
            }
        }
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ThrottleDecorator
    
    private func makeSUT(
        delay: TimeInterval = 0.1,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(delay: delay)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
