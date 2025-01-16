//
//  ContentFlowWitnesses+ext.swift
//
//
//  Created by Igor Malyarov on 04.01.2025.
//

import Combine

public extension ContentFlowWitnesses {
    
    /// Binds `Content` and `Flow` using this `ContentFlowWitnesses` configuration.
    ///
    /// - The `contentEmitting` publisher is subscribed, and its events are forwarded
    ///   to the flow via `flowReceiving`.
    /// - The flow's navigation is observed via `flowEmitting`. When navigation transitions
    ///   from non-nil to nil, `contentDismissing` is invoked.
    func bind(
        content: Content,
        flow: Flow
    ) -> Set<AnyCancellable> {
        
        let contentEvents = contentEmitting(content)
            .sink(receiveValue: flowReceiving(flow))
        
        let flowEmitting = flowEmitting(flow)
        let dismiss = flowEmitting
            .prepend(nil)
            .zip(flowEmitting)
            .filter { $0.0 != nil && $0.1 == nil }
            .map { _ in () }
            .sink(receiveValue: contentDismissing(content))
        
        return [contentEvents, dismiss]
    }
}
