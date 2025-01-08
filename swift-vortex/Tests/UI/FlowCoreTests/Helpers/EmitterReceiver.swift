//
//  EmitterReceiver.swift
//
//
//  Created by Igor Malyarov on 04.01.2025.
//

import Combine
import FlowCore

final class EmitterReceiver<Emit, Receive> {
    
    private let subject = PassthroughSubject<Emit, Never>()
    private(set) var received = [Receive]()
    
    var callCount: Int { received.count }
    
    var publisher: AnyPublisher<Emit, Never> {
        
        subject.eraseToAnyPublisher()
    }
    
    func emit(_ emit: Emit) {
        
        subject.send(emit)
    }
    
    func receive(_ receive: Receive) {
        
        received.append(receive)
    }
}

extension EmitterReceiver where Receive == Void {
    
    func witnesses<Select>(
    ) -> ContentWitnesses<EmitterReceiver, Emit>
    where Emit == FlowEvent<Select, Never> {
        
        return .init(
            emitting: { $0.publisher },
            dismissing: { content in { content.receive(()) }}
        )
    }
    
    func selectWitnesses() -> ContentWitnesses<EmitterReceiver, Emit> {
        
        return .init(
            emitting: { $0.publisher },
            dismissing: { content in { content.receive(()) }}
        )
    }
}
