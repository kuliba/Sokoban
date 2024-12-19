//
//  Node.swift
//  Vortex
//
//  Created by Igor Malyarov on 31.07.2024.
//

import Combine

public struct Node<Model> {
    
    public let model: Model
    private let cancellables: Set<AnyCancellable>
    
    public init(
        model: Model,
        cancellables: Set<AnyCancellable>
    ) {
        self.model = model
        self.cancellables = cancellables
    }
    
    public init(
        model: Model,
        cancellable: AnyCancellable
    ) {
        self.model = model
        self.cancellables = [cancellable]
    }
}

extension Node: Equatable where Model: Equatable {}
