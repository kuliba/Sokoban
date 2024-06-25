//
//  RetryPolicy.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import Foundation

/// A struct that defines the retry policy with parameters for maximum retries and the strategy to use.
public struct RetryPolicy: Equatable {
    
    public let maxRetries: Int
    public let strategy: Strategy
    
    /// Initialises a new instance of `RetryPolicy`.
    ///
    /// - Parameters:
    ///   - maxRetries: The maximum number of retry attempts.
    ///   - strategy: The strategy to use for calculating retry intervals.
    public init(
        maxRetries: Int,
        strategy: Strategy
    ) {
        self.maxRetries = maxRetries
        self.strategy = strategy
    }
}

public extension RetryPolicy {
    
    /// The strategy for calculating retry intervals.
    enum Strategy: Equatable {
        
        case equal(interval: DispatchTimeInterval)
        case exponential(baseDelay: DispatchTimeInterval, jitter: Bool)
    }
}

public extension RetryPolicy {
    
    /// Returns the retry intervals based on the strategy and the number of retries left.
    ///
    /// - Returns: An array of retry intervals.
    func getRetryIntervals() -> [DispatchTimeInterval] {
        
        guard maxRetries > 0 else { return [] }
        switch strategy {
        case let .equal(interval: interval):
            return .init(repeating: interval, count: maxRetries)
            
        case let .exponential(baseDelay: baseDelay, jitter: jitter):
            return (0..<maxRetries).map { attempt in
                
                return interval(attempt, baseDelay, jitter)
            }
        }
    }
}

private extension RetryPolicy {
    
    /// Helper function to calculate exponential retry intervals.
    ///
    /// - Parameters:
    ///   - baseDelay: The base delay for the exponential backoff.
    ///   - jitter: Whether to add jitter to the delay.
    /// - Returns: An array of exponential retry intervals.
    func interval(
        _ attempt: Int,
        _ baseDelay: DispatchTimeInterval,
        _ jitter: Bool
    ) -> DispatchTimeInterval {
        
        var delay: TimeInterval
        switch baseDelay {
        case .seconds(let value):
            delay = TimeInterval(value) * pow(2.0, Double(attempt))
            
        case .milliseconds(let value):
            delay = TimeInterval(value) / 1_000.0 * pow(2.0, Double(attempt))
            
        case .microseconds(let value):
            delay = TimeInterval(value) / 1_000_000.0 * pow(2.0, Double(attempt))
            
        case .nanoseconds(let value):
            delay = TimeInterval(value) / 1_000_000_000.0 * pow(2.0, Double(attempt))
            
        case .never:
            return .never
            
        @unknown default:
            delay = 1.0 * pow(2.0, Double(attempt))  // Default to 1 second if unknown type
        }
        
        if jitter {
            delay += TimeInterval.random(in: 0...delay)
        }
        
        return .milliseconds(Int(delay * 1_000))
    }
}
