//
//  Operator.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

import Tagged

public struct Operator: Equatable, Identifiable {
    
    public let id: ID
    
    public init(
        id: ID
    ) {
        self.id = id
    }
}

public extension Operator {
    
    typealias ID = Tagged<Self, String>
}
