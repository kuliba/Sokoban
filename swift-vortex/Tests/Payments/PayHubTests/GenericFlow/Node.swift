//
//  Node.swift
//
//
//  Created by Igor Malyarov on 02.01.2025.
//

import Combine

#warning("original Node is located in PayHubUI module")
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
