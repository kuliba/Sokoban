//
//  Publisher+diff.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import Combine

extension Publisher where Failure == Never {
    
    /// Transforms the output of the publisher into a stream of differences using a provided transformation function.
    ///
    /// This method compares each emitted value with the previous one and uses the provided transformation function
    /// to generate a `Projection` that represents the difference. If the transformation function returns `nil`,
    /// no value is emitted.
    ///
    /// - Parameter transform: A closure that takes the previous and current output values and returns an optional `Projection`.
    /// - Returns: A publisher that emits the differences as `Projection` values.
    ///
    /// The closure receives:
    /// - `previous`: The previous output value, or `nil` if there was no previous value.
    /// - `current`: The current output value.
    public func diff<Projection>(
        using transform: @escaping (_ previous: Output?, _ current: Output) -> Projection?
    ) -> AnyPublisher<Projection, Never> {
        
        self.scan((Output?.none, Output?.none)) { ($0.1, $1) }
            .compactMap { previous, current in
                
                guard let current else { return nil }
                return transform(previous, current)
            }
            .eraseToAnyPublisher()
    }
}
