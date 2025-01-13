//
//  ContentFlowWitnesses.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine

public struct ContentFlowWitnesses<Content, Flow, Select, Navigation> {
    
    public let contentEmitting: ContentEmitting
    public let contentDismissing: ContentDismissing
    public let flowEmitting: FlowEmitting
    public let flowReceiving: FlowReceiving
    
    public init(
        contentEmitting: @escaping ContentEmitting,
        contentDismissing: @escaping ContentDismissing,
        flowEmitting: @escaping FlowEmitting,
        flowReceiving: @escaping FlowReceiving
    ) {
        self.contentEmitting = contentEmitting
        self.contentDismissing = contentDismissing
        self.flowEmitting = flowEmitting
        self.flowReceiving = flowReceiving
    }
}

public extension ContentFlowWitnesses {
    
    typealias ContentEmitting = (Content) -> AnyPublisher<FlowEvent<Select, Never>, Never>
    typealias ContentDismissing = (Content) -> () -> Void
    typealias FlowEmitting = (Flow) -> AnyPublisher<Navigation?, Never>
    typealias FlowReceiving = (Flow) -> (FlowEvent<Select, Never>) -> Void
}
