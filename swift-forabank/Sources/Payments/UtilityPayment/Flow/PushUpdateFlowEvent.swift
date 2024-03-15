//
//  PushUpdateFlowEvent.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

public enum PushUpdateFlowEvent<PushEvent, UpdateEvent> {
    
    case push(PushEvent)
    case update(UpdateEvent)
}

extension PushUpdateFlowEvent: Equatable where PushEvent: Equatable, UpdateEvent: Equatable {}
