//
//  ContentFlowWitnesses.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine

public struct ContentFlowWitnesses<Content, Flow, Select, Navigation> {
    
    public let contentEmitting: ContentEmitting
    public let contentReceiving: ContentReceiving
    public let flowEmitting: FlowEmitting
    public let flowReceiving: FlowReceiving
    
    public init(
        contentEmitting: @escaping ContentEmitting,
        contentReceiving: @escaping ContentReceiving,
        flowEmitting: @escaping FlowEmitting,
        flowReceiving: @escaping FlowReceiving
    ) {
        self.contentEmitting = contentEmitting
        self.contentReceiving = contentReceiving
        self.flowEmitting = flowEmitting
        self.flowReceiving = flowReceiving
    }
}

public extension ContentFlowWitnesses {
    
    typealias ContentEmitting = (Content) -> AnyPublisher<Select, Never>
    typealias ContentReceiving = (Content) -> () -> Void
    typealias FlowEmitting = (Flow) -> AnyPublisher<Navigation?, Never>
    typealias FlowReceiving = (Flow) -> (Select) -> Void
}
