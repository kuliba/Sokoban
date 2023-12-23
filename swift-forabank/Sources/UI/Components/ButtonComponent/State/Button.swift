//
//  File.swift
//
//
//  Created by Igor Malyarov on 23.12.2023.
//

import SharedConfigs

public struct Button: Equatable {
    
    public let id: ID
    public let value: String
    public let color: Color
    public let action: Action
    public let placement: Placement
    
    public init(
        id: ID,
        value: String,
        color: Color,
        action: Action,
        placement: Placement
    ) {
        self.id = id
        self.value = value
        self.color = color
        self.action = action
        self.placement = placement
    }
}

public extension Button {
    
    enum Action: Equatable {
        
        case pay
    }
    
    enum ID: Equatable {
        
        case buttonPay
    }
    
    enum Color: Equatable {
        
        case red
    }
    
    enum Placement: Equatable {
        
        case bottom
    }
}
