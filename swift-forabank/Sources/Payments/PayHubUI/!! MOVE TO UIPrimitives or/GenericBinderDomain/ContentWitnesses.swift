//
//  ContentWitnesses.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine

public struct ContentWitnesses<Content, Select> {
    
    public let emitting: Emitting
    public let receiving: Receiving
    
    public init(
        emitting: @escaping Emitting,
        receiving: @escaping Receiving
    ) {
        self.emitting = emitting
        self.receiving = receiving
    }
}

public extension ContentWitnesses {
    
    typealias Emitting = (Content) -> AnyPublisher<Select, Never>
    typealias Receiving = (Content) -> () -> Void
}
