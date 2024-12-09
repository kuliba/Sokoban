//
//  FlowEvent.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum FlowEvent<Select, Navigation> {
    
    case dismiss
    case receive(Navigation)
    case select(Select)
}

extension FlowEvent: Equatable where Select: Equatable, Navigation: Equatable {}
