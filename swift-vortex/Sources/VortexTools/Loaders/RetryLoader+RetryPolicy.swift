//
//  RetryLoader+RetryPolicy.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import CombineSchedulers
import Foundation

public extension RetryLoader {
    
    /// Convenience initialiser to create `RetryLoader` using a `RetryPolicy`.
    ///
    /// - Parameters:
    ///   - performer: The loader to be decorated with retry logic.
    ///   - retryPolicy: The policy that defines the retry intervals.
    ///   - scheduler: A scheduler for managing the retry timing.
    convenience init(
        performer: any Performer,
        retryPolicy: RetryPolicy,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.init(
            performer: performer,
            getRetryIntervals: { _ in retryPolicy.getRetryIntervals() },
            scheduler: scheduler
        )
    }
}
