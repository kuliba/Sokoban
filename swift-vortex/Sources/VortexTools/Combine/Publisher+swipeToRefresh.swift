//
//  Publisher+swipeToRefresh.swift
//
//
//  Created by Igor Malyarov on 01.03.2025.
//

import Combine
import CombineSchedulers
import Foundation

/// Configuration parameters for the refresh pipeline.
public struct SwipeToRefreshConfig {
    
    /// Minimum offset required to trigger refresh.
    public let threshold: CGFloat
    /// Debounce interval (the period during which offset events are collected).
    public let debounceInterval: DebounceInterval
    
    public init(
        threshold: CGFloat,
        debounceInterval: DebounceInterval
    ) {
        self.threshold = threshold
        self.debounceInterval = debounceInterval
    }
    
    public typealias DebounceInterval = DispatchQueue.SchedulerTimeType.Stride
}

public extension Publisher where Output == CGFloat, Failure == Never {
    
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

