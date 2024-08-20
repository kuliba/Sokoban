//
//  Binder.swift
//
//
//  Created by Igor Malyarov on 19.08.2024.
//

import Combine

public final class Binder<Content, Flow> {
    
    public let content: Content
    public let flow: Flow
    
    private let cancellable: AnyCancellable?
    
    public init(
        content: Content,
        flow: Flow,
        bind: ((Content, Flow) -> AnyCancellable?)? = nil
    ) {
        self.content = content
        self.flow = flow
        self.cancellable = bind?(content, flow)
    }
}
