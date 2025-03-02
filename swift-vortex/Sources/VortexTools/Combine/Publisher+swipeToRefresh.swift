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
    
    /// Triggers a refresh action when a valid pull-to-refresh gesture is detected.
    ///
    /// This operator monitors a stream of offset values (for example, from a scroll view). It collects offset events during a specified time interval (the debounce period) and determines the maximum offset reached during that period. If the maximum offset is equal to or exceeds the configured threshold, it invokes the refresh action. Once the debounce period completes, the collected state resets, allowing subsequent valid pull gestures to trigger refresh again.
    ///
    /// - Parameters:
    ///   - refresh: A closure that is called when a valid pull-to-refresh gesture is detected.
    ///   - config: A configuration that specifies the minimum offset threshold and the debounce interval.
    ///   - scheduler: The scheduler used to control the timing of the debounce period.
    /// - Returns: An `AnyCancellable` that must be retained to keep the subscription active.
    func swipeToRefresh(
        refresh: @escaping () -> Void,
        config: SwipeToRefreshConfig,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> AnyCancellable {
        
        return self
            .scan((current: CGFloat.zero, max: CGFloat.zero)) { acc, newValue in
                
                return (current: newValue, max: Swift.max(acc.max, newValue))
            }
            .debounce(for: config.debounceInterval, scheduler: scheduler)
            .filter { $0.max >= config.threshold }
            .sink { _ in refresh() }
    }
}
