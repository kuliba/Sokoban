//
//  Node.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Combine

struct Node<Model> {
    
    let model: Model
    private let cancellables: Set<AnyCancellable>
    
    init(
        model: Model,
        cancellable: AnyCancellable
    ) {
        self.model = model
        self.cancellables = [cancellable]
    }
    
    init(
        model: Model,
        cancellables: Set<AnyCancellable>
    ) {
        self.model = model
        self.cancellables = cancellables
    }
}

extension Node: Equatable where Model: Equatable {}
