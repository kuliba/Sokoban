//
//  FlowTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import ForaTools

struct Flow<Destination> {
    
    private(set) var stack: Stack<Destination>
    
    init(stack: Stack<Destination> = .init([])) {
        
        self.stack = stack
    }
}

extension Flow {
    
    var current: Destination? {
        
        get { stack.top }
        set { stack.top = newValue }
    }
    
    mutating func push(_ destination: Destination) {
        
        stack.push(destination)
    }
}

extension Flow: Equatable where Destination: Equatable {}

enum FlowEvent<PushEvent, UpdateEvent> {
    
    case push(PushEvent)
    case update(UpdateEvent)
}

extension FlowEvent: Equatable where PushEvent: Equatable, UpdateEvent: Equatable {}

enum FlowEffect<PushEffect, UpdateEffect> {
    
    case push(PushEffect)
    case update(UpdateEffect)
}

extension FlowEffect: Equatable where PushEffect: Equatable, UpdateEffect: Equatable {}
