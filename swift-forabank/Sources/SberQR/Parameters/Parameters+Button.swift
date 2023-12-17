//
//  Parameters+Button.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct Button<Action, ID> {
        
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
}

extension Parameters.Button: Equatable where Action: Equatable, ID: Equatable {}
