//
//  RetryPolicyTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import ForaTools
import XCTest

final class RetryPolicyTests: XCTestCase {
    
    // MARK: - equal
    
    func test_getRetryIntervals_equal_shouldDeliverEmptyIntervalsForNegativeMacRetries() {
        
        XCTAssertNoDiff(equal(maxRetries: -1), [])
    }
    
    func test_getRetryIntervals_equal_shouldDeliverEmptyIntervalsForZeroMacRetries() {
        
        XCTAssertNoDiff(equal(maxRetries: 0), [])
    }
    
    func test_getRetryIntervals_equal_shouldDeliverOneIntervalForOneMacRetries() {
        
        XCTAssertNoDiff(
            equal(maxRetries: 1, .milliseconds(1_234)),
            [.milliseconds(1_234)]
        )
    }
    
    func test_getRetryIntervals_equal_shouldDeliverTwoIntervalsForTwoMacRetries() {
        
        XCTAssertNoDiff(
            equal(maxRetries: 2, .milliseconds(4_321)),
            [.milliseconds(4_321), .milliseconds(4_321)]
        )
    }
    
    func test_getRetryIntervals_exponential_withoutJitter_shouldReturnExponentialIntervals() {
        
        XCTAssertNoDiff(exponential(maxRetries: 3, base: .milliseconds(1_000)), [
            DispatchTimeInterval.milliseconds(1_000),
            DispatchTimeInterval.milliseconds(2_000),
            DispatchTimeInterval.milliseconds(4_000)
        ])
    }
    
    // MARK: - Helpers
    
    private func getRetryIntervals(
        _ policy: RetryPolicy
    ) -> [DispatchTimeInterval] {
        
        return policy.getRetryIntervals()
    }
    
    private func getRetryIntervals(
        maxRetries: Int,
        strategy: RetryPolicy.Strategy
    ) -> [DispatchTimeInterval] {
        
        return getRetryIntervals(
            .init(maxRetries: maxRetries, strategy: strategy)
        )
    }
    
    private func equal(
        maxRetries: Int,
        _ interval: DispatchTimeInterval? = nil
    ) -> [DispatchTimeInterval] {
        
        let interval = interval ?? anyDispatchTimeInterval()
        
        let policy = RetryPolicy(
            maxRetries: maxRetries,
            strategy: .equal(interval: interval)
        )
        
        return policy.getRetryIntervals()
    }
    
    private func exponential(
        maxRetries: Int,
        base baseDelay: DispatchTimeInterval,
        jitter: Bool = false
    ) -> [DispatchTimeInterval] {
        
        let policy = RetryPolicy(
            maxRetries: maxRetries,
            strategy: .exponential(baseDelay: baseDelay, jitter: jitter)
        )
        
        return policy.getRetryIntervals()
    }
    
    private func anyDispatchTimeInterval(
        _ milliseconds: Int = .random(in: 0...1_000)
    ) -> DispatchTimeInterval {
        
        return .milliseconds(milliseconds)
    }
}
