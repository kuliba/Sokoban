//
//  QRFlowBinder.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import Combine

final class QRFlowBinder<Content, Flow>
where Content: QRFlowContentEventEmitter,
      Flow: QRFlowContentEventReceiver,
      Content.ScanResult == Flow.ScanResult {
    
    let content: Content
    let flow: Flow
    
    private let cancellable: AnyCancellable
    
    init(
        content: Content,
        flow: Flow
    ) {
        self.content = content
        self.flow = flow
        
        cancellable = content.qrFlowContentEventPublisher
            .sink { flow.receive($0) }
    }
}
