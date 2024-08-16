//
//  PayHubBinder.swift
//
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Combine

public final class PayHubBinder<Content, Flow>
where Content: PayHubItemSelector,
      Flow: PayHubItemReceiver,
      Content.Latest == Flow.Latest {
    
    public let content: Content
    public let flow: Flow
    
    private let cancellable: AnyCancellable
    
    public init(
        content: Content,
        flow: Flow
    ) {
        self.content = content
        self.flow = flow
        
        cancellable = content.selectPublisher.sink { flow.receive($0) }
    }
}
