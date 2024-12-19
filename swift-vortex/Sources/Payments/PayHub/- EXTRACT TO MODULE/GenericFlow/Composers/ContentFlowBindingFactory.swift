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
        
        let select = witnesses.contentEmitting(content)
            .sink { witnesses.flowReceiving(flow)($0) }
        
        let flowEmitting = witnesses.flowEmitting(flow)
        let dismiss = flowEmitting
            .prepend(nil)
            .zip(flowEmitting)
            .filter { $0.0 != nil && $0.1 == nil }
            .sink { _ in witnesses.contentDismissing(content)() }
        
        return [select, dismiss]
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
