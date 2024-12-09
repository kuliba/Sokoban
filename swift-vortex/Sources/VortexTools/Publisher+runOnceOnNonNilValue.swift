//
//  Publisher+runOnceOnNonNilValue.swift
//  
//
//  Created by Igor Malyarov on 11.10.2024.
//

import Combine

public extension Publisher where Failure == Never {
    
    /// Executes the provided work closure once when the publisher emits the first non-nil value.
    /// - Parameter work: The closure to be executed when a non-nil value is emitted.
    /// - Returns: An `AnyCancellable` that can be used to manage the subscription.
    /// - Note: The execution queue of the work closure will depend on the queue where the publisher emits. If you need the work to be executed on a specific queue (e.g., the main queue), use `.receive(on:)` before calling `runOnceOnValue`.
    ///
    /// Example:
    /// ```swift
    /// publisher
    ///     .receive(on: DispatchQueue.main)
    ///     .runOnceOnValue {
    ///         // Work to be done on the main queue
    ///     }
    /// ```
    func runOnceOnNonNilValue<Wrapped>(
        _ work: @escaping () -> Void
    ) -> AnyCancellable where Output == Optional<Wrapped> {
        
        return self
            .compactMap { $0 }
            .prefix(1)
            .sink { _ in work() }
    }
}
