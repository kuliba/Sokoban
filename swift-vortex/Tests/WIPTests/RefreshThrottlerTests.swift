//
//  RefreshThrottlerTests.swift
//
//
//  Created by Igor Malyarov on 19.01.2025.
//

import Foundation

struct RefreshThrottler {
    
    private let minimumInterval: DispatchTimeInterval
    private var lastRefreshDate: Date?
    private let currentTime: () -> Date
    
    init(
        minimumInterval: DispatchTimeInterval,
        currentTime: @escaping () -> Date = Date.init
    ) {
        self.minimumInterval = minimumInterval
        self.currentTime = currentTime
    }
    
    mutating func execute(
        _ refreshAction: () -> Void
    ) -> Bool {
        
        let now = currentTime()
        if let lastRefresh = lastRefreshDate,
           now.timeIntervalSince(lastRefresh) < minimumInterval.seconds {
            return false
        }
        
        refreshAction()
        lastRefreshDate = now
        return true
    }
}

private extension DispatchTimeInterval {
    
    var seconds: TimeInterval {
        
        switch self {
        case .seconds(let value): return TimeInterval(value)
        case .milliseconds(let value): return TimeInterval(value) / 1_000
        case .microseconds(let value): return TimeInterval(value) / 1_000_000
        case .nanoseconds(let value): return TimeInterval(value) / 1_000_000_000
        case .never: return .infinity
        @unknown default: return .infinity
        }
    }
}

import XCTest

final class RefreshThrottlerTests: XCTestCase {
    
    func test_execute_shouldAllowRefresh_onInitialCall() {
        
        var sut = makeSUT(minimumInterval: .seconds(180))
        let didRefresh = sut.execute { }
        
        XCTAssertTrue(didRefresh, "Expected first refresh to succeed since no previous refresh occurred.")
    }
    
    func test_execute_shouldBlockRefresh_onCooldownPeriod() {
        
        var now = Date()
        var sut = makeSUT(minimumInterval: .seconds(180), currentTime: { now })
        
        _ = sut.execute { }
        
        now.addTimeInterval(179)
        let didRefresh = sut.execute { }
        
        XCTAssertFalse(didRefresh, "Expected refresh to be blocked when attempted before cooldown ends.")
    }
    
    func test_execute_shouldAllowRefresh_onCooldownExpiry() {
        
        var now = Date()
        var sut = makeSUT(minimumInterval: .seconds(180), currentTime: { now })
        
        _ = sut.execute { }
        
        now.addTimeInterval(180)
        let didRefresh = sut.execute { }
        
        XCTAssertTrue(didRefresh, "Expected refresh to succeed after cooldown period.")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        minimumInterval: DispatchTimeInterval,
        currentTime: @escaping () -> Date = Date.init
    ) -> RefreshThrottler {
        
        return .init(minimumInterval: minimumInterval, currentTime: currentTime)
    }
}
