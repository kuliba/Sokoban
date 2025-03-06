//
//  SwipeToRefresh.swift
//  Vortex
//
//  Created by Andryusina Nataly on 02.03.2025.
//

import Combine
import CombineSchedulers
import SwiftUI

struct SwipeToRefreshConfig {
    /// Minimum threshold offset to trigger refresh (typically negative for pull-down)
    let threshold: CGFloat
    
    /// Debounce interval for collecting offset events
    let debounceInterval: DispatchQueue.SchedulerTimeType.Stride
    
    /// Creates a new configuration for swipe-to-refresh behavior
    /// - Parameters:
    ///   - threshold: The minimum offset to trigger a refresh (typically a negative value)
    ///   - debounceInterval: The time interval to debounce scroll events
    init(
        threshold: CGFloat = -100,
        debounceInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(2)
    ) {
        self.threshold = threshold
        self.debounceInterval = debounceInterval
    }
}

// MARK: - CGPoint Publisher Extension

extension Publisher where Output == CGPoint, Failure == Never {
    /// Transforms a stream of CGPoint values into a trigger for refresh actions based on scroll behavior.
    /// This operator monitors vertical scroll offsets and triggers the refresh action when:
    /// 1. The offset exceeds the specified threshold
    /// 2. The user is actively scrolling downward (not upward)
    /// 3. The scroll has settled for the debounce interval
    ///
    /// - Parameters:
    ///   - config: Configuration options for threshold and debounce timing
    ///   - scheduler: The scheduler to perform the debounce operation on
    ///   - onChange: Action to perform when conditions for refresh are met
    /// - Returns: A cancellable object representing the subscription
    func swipeToRefresh(
        config: SwipeToRefreshConfig = SwipeToRefreshConfig(),
        scheduler: AnySchedulerOf<DispatchQueue>,
        onChange: @escaping () -> Void
    ) -> AnyCancellable {
        
        // Extract the Y offset from CGPoint
        let yOffsetPublisher = self.map(\.y)
        
        // Track scroll direction (positive = scrolling up, negative = scrolling down)
        let scrollDirectionPublisher = yOffsetPublisher
            .scan((previous: CGFloat.zero, direction: CGFloat.zero)) { acc, newValue in
                let direction = newValue > acc.previous ? 1 : -1
                return (previous: newValue, direction: CGFloat(direction))
            }
            .map(\.direction)
            .dropFirst() // Skip initial value
            .removeDuplicates()
        
        // Track if offset exceeds threshold
        let thresholdExceededPublisher = yOffsetPublisher
            .map { $0 < config.threshold }
            .removeDuplicates()
        
        // Combine conditions: threshold exceeded AND scrolling downward
        let shouldRefreshPublisher = Publishers.CombineLatest(
            thresholdExceededPublisher,
            scrollDirectionPublisher
        )
            .map { thresholdExceeded, direction in
                return thresholdExceeded && direction < 0
            }
            .removeDuplicates()
        
        // Apply debounce to ensure scroll has settled
        let debouncedOffsetPublisher = self
            .debounce(for: config.debounceInterval, scheduler: scheduler)
        
        // Final pipeline: trigger onChange only when all conditions are met
        return shouldRefreshPublisher
            .combineLatest(debouncedOffsetPublisher)
            .compactMap { shouldRefresh, _ in
                return shouldRefresh ? () : nil
            }
            .sink { _ in onChange() }
    }
}
