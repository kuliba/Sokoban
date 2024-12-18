//
//  AnyReactiveUpdater.swift
//  
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public struct AnyReactiveUpdater<T, V> {
    
    private let _update: Update
    
    public init(update: @escaping Update) {
        
        self._update = update
    }
    
    public typealias Update = (T) -> AnyPublisher<V, Never>
}

extension AnyReactiveUpdater: ReactiveUpdater {
    
    public func update(_ t: T) -> AnyPublisher<V, Never> {
        
        return self._update(t)
    }
}
