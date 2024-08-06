//
//  Node.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2024.
//

import Combine

struct Node<Model> {
    
    let model: Model
    private let cancellables: Set<AnyCancellable>
    
    init(
        model: Model,
        cancellables: Set<AnyCancellable>
    ) {
        self.model = model
        self.cancellables = cancellables
    }
    
    init(
        model: Model,
        cancellable: AnyCancellable
    ) {
        self.model = model
        self.cancellables = [cancellable]
    }
}

extension Node: Equatable where Model: Equatable {}
