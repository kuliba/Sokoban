//
//  Node.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2024.
//

import Combine

struct Node<Model> {
    
    let model: Model
    private let cancellable: AnyCancellable
    
    init(
        model: Model,
        cancellable: AnyCancellable
    ) {
        self.model = model
        self.cancellable = cancellable
    }
}

extension Node: Equatable where Model: Equatable {}
