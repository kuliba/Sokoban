//
//  PaymentsTransfersBinder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

public final class PaymentsTransfersBinder<Content, Flow> {
    
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
