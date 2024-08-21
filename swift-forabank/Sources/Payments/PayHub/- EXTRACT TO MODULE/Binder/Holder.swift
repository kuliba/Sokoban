//
//  Holder.swift
//
//
//  Created by Igor Malyarov on 19.08.2024.
//

import Combine

/// Like `Binder` but without subscription.
public final class Holder<Content, Flow> {
    
    public let content: Content
    public let flow: Flow
    
    public init(
        content: Content,
        flow: Flow
    ) {
        self.content = content
        self.flow = flow
    }
}
