//
//  Templates.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Combine
import PayHub

final class Templates: FlowEventEmitter {
    
    private let subject = PassthroughSubject<FlowEvent, Never>()
    
    var eventPublisher: AnyPublisher<FlowEvent, Never> {
        
        subject.eraseToAnyPublisher()
    }
}
