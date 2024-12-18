//
//  ReactiveUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public protocol ReactiveUpdater<T, V> {
    
    associatedtype T
    associatedtype V
    
    func update(_ t: T) -> AnyPublisher<V, Never>
}
