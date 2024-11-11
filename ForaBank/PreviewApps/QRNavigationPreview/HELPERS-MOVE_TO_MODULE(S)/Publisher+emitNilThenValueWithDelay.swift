//
//  Publisher+emitNilThenValueWithDelay.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 30.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

extension Publisher where Failure == Never {
    
    /// Emits `nil` immediately, then emits the first non-`nil` value after a delay.
    ///
    /// This method is useful when you need to perform an immediate action (like dismissing a view)
    /// followed by another action (like navigation) after a specified delay.
    ///
    /// - Parameters:
    ///   - delay: The time to wait before emitting the non-`nil` value.
    ///   - scheduler: The scheduler on which to perform the delay.
    /// - Returns: A publisher that first emits `nil`, then emits the non-`nil` value after the delay.
    func emitNilThenValueWithDelay<Value>(
        delay: DispatchQueue.SchedulerTimeType.Stride,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> AnyPublisher<Value?, Never> where Output == Optional<Value> {
        
        self.compactMap { $0 }
            .prefix(1) // Take only the first value, safe to store forever
            .map { [Value?.none, $0] } // emit nil first
            .flatMap {
                
                $0.publisher.flatMap {
                    
                    Just($0)
                        .delay(for: $0 == nil ? 0 : delay, scheduler: scheduler) // emit real value with delay
                }
            }
            .eraseToAnyPublisher()
    }
}
