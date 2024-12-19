//
//  ReactiveUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

/// A protocol for types that can reactively update a `T` into a stream of `V` values.
public protocol ReactiveUpdater<T, V> {
    
    associatedtype T
    associatedtype V
    
    /// Produces a publisher of `V` values for a given `T`.
    func update(_ t: T) -> AnyPublisher<V, Never>
}
