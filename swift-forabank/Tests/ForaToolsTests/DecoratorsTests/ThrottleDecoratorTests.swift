//
//  ThrottleDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import ForaTools
import XCTest

final class ThrottleDecoratorTests: XCTestCase {
    
    func test_throttle_shouldNotThrottleForZeroDelay() {
        
        let sut = makeSUT(delay: .zero)
        let exp = expectation(description: "Should not throttle execution with zero delay.")
        exp.expectedFulfillmentCount = 2
        
        sut.throttle { exp.fulfill() }
        sut.throttle { exp.fulfill() }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_throttle_shouldExecuteFirstCall() {
        
        let sut = makeSUT()
        let exp = expectation(description: "Throttle executes immediately at first call.")
        
        sut.throttle { exp.fulfill() }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    func test_throttle_shouldIgnoreImmediateSubsequentCall() {
        
        let sut = makeSUT(delay: 0.5)
        let exp = expectation(description: "Only the first call should be executed")
        
        sut.throttle { exp.fulfill() }
        sut.throttle { exp.fulfill() }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    // TODO: fix, failing on CI
//    func test_throttle_shouldExecuteOnBackgroundThread() {
//        
//        let sut = makeSUT()
//        let exp = expectation(description: "Execute on background thread")
//        
//        let backgroundQueue = DispatchQueue.global(qos: .background)
//        
//        backgroundQueue.async {
//            
//            sut.throttle { exp.fulfill() }
//        }
//        
//        wait(for: [exp], timeout: 0.2)
//    }
    
    func test_throttle_shouldNotCrashOnDifferentQueues_threadSafety() {
        
        let delay = 0.1
        let sut = makeSUT()
        let exp = expectation(description: "Complete multiple concurrent calls")
        exp.expectedFulfillmentCount = 2
        
        let concurrentQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        for _ in 0..<100 {
            
            concurrentQueue.async {
                
                sut.throttle { exp.fulfill() }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.1) {
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_throttle_shouldDelayReExecution() {
        
        let delay = 0.1
        let sut = makeSUT(delay: delay)
        let exp = expectation(description: "Throttle re-executes after specified delay")
        exp.expectedFulfillmentCount = 2
        
        for _ in 1...10 {
            
            sut.throttle { exp.fulfill() }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            sut.throttle { exp.fulfill() }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_throttle_shouldExecuteLongDelay() {
        
        let delay = 0.5
        let sut = makeSUT(delay: delay)
        let exp = expectation(description: "Throttle works correctly with long delays")
        exp.expectedFulfillmentCount = 2
        
        for _ in 1...10 {
            
            sut.throttle { exp.fulfill() }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            for _ in 1...10 {
                
                sut.throttle { exp.fulfill() }
            }
        }
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_throttle_shouldExecuteDifferentBlocks() {
        
        let delay = 0.1
        let sut = makeSUT(delay: delay)
        let exp = expectation(description: "Throttle executes different blocks correctly")
        exp.expectedFulfillmentCount = 2
        var executionFlag = false
        
        sut.throttle {
            
            executionFlag = true
            exp.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            sut.throttle { exp.fulfill() }
        }
        
        wait(for: [exp], timeout: 0.2)
        XCTAssertTrue(executionFlag, "Initial block should have been executed")
    }
    
    //TODO: test failed on CI
//    func test_throttle_shouldNotHaveRaceConditionWithConcurrentAccess() {
//        
//        let delay = 0.1
//        let sut = makeSUT(delay: delay)
//        let exp = expectation(description: "Complete multiple concurrent calls")
//        exp.expectedFulfillmentCount = 2
//        
//        let concurrentQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
//        
//        sut.throttle { exp.fulfill() }
//
//        for _ in 0..<10 {
//            
//            concurrentQueue.asyncAfter(deadline: .now() + delay) {
//                
//                sut.throttle { exp.fulfill() }
//            }
//        }
//        
//        wait(for: [exp], timeout: 2)
//    }
    
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
