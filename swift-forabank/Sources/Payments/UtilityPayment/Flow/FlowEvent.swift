//
//  FlowEvent.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

public enum FlowEvent<PushEvent, UpdateEvent> {
    
    case push(PushEvent)
    case update(UpdateEvent)
}

extension FlowEvent: Equatable where PushEvent: Equatable, UpdateEvent: Equatable {}
