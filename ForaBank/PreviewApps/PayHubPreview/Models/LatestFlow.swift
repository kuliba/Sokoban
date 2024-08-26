//
//  LatestFlow.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Combine
import PayHub

final class LatestFlow: FlowEventEmitter {
    
    let latest: Latest
    
    private let subject = PassthroughSubject<FlowEvent, Never>()
    
    init(
        latest: Latest
    ) {
        self.latest = latest
    }
    
    var eventPublisher: AnyPublisher<FlowEvent, Never> {
        
        subject.eraseToAnyPublisher()
    }
}
