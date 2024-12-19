//
//  AnyReactiveUpdater.swift
//  
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

/// A type-erased reactive updater that transforms a `T` into a stream of `V` values over time.
public struct AnyReactiveUpdater<T, V> {
    
    private let _update: Update
    
    /// Creates a type-erased reactive updater from a given update closure.
    ///
    /// - Parameter update: A closure that returns a publisher of `V` values for a given `T`.
    public init(update: @escaping Update) {
        
        self._update = update
    }
    
    /// A closure type that takes a `T` and returns a publisher of `V` values.
    public typealias Update = (T) -> AnyPublisher<V, Never>
}

extension AnyReactiveUpdater: ReactiveUpdater {
    
    /// Updates the given `t` by producing a publisher of `V` values.
    public func update(_ t: T) -> AnyPublisher<V, Never> {
        
        return self._update(t)
    }
}
