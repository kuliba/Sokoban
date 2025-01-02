//
//  ContentFlowBindingFactory.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

public final class ContentFlowBindingFactory {
    
    public init() {}
}

public extension ContentFlowBindingFactory {
    
    func bind<Content, Flow, Select, Navigation>(
        content: Content,
        flow: Flow,
        witnesses: ContentFlowWitnesses<Content, Flow, Select, Navigation>
    ) -> Set<AnyCancellable> {
        
        // Process events emitted from the content.
        let contentEvents = witnesses.contentEmitting(content)
            .sink(receiveValue: witnesses.flowReceiving(flow))
        
        // Handle dismissal when the flow's navigation changes from non-nil to nil.
        let flowEmitting = witnesses.flowEmitting(flow)
        let dismiss = flowEmitting
            .prepend(nil)
            .zip(flowEmitting)
            .filter { $0.0 != nil && $0.1 == nil }
            .map { _ in () }
            .sink(receiveValue: witnesses.contentDismissing(content))
        
        return [contentEvents, dismiss]
    }
}

public extension ContentFlowBindingFactory {
    
    func bind<Content, Flow, Select, Navigation>(
        with witnesses: ContentFlowWitnesses<Content, Flow, Select, Navigation>
    ) -> (Content, Flow) -> Set<AnyCancellable> {
        
        return { content, flow in
            
            return self.bind(content: content, flow: flow, witnesses: witnesses)
        }
    }
}
