//
//  Flow.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import ForaTools

public struct Flow<Destination> {
    
    public private(set) var stack: Stack<Destination>
    
    public init(stack: Stack<Destination> = .init([])) {
        
        self.stack = stack
    }
}

public extension Flow {
    
    var current: Destination? {
        
        get { stack.top }
        set { stack.top = newValue }
    }
    
    var isEmpty: Bool { stack.isEmpty }
    
    mutating func push(_ destination: Destination) {
        
        stack.push(destination)
    }
}

extension Flow: Equatable where Destination: Equatable {}
