//
//  ServerCommandParameter.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.09.2023.
//

public struct ServerCommandParameter: CustomDebugStringConvertible {
    
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        
        self.name = name
        self.value = value
    }
    
    public var debugDescription: String { "\(name), \(value)" }
}
