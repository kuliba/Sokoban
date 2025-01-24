//
//  SerialStamped+description.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.01.2025.
//

import RemoteServices
import SerialComponents

// MARK: - SerialStamped for Single Value

extension SerialComponents.SerialStamped: CustomStringConvertible {
    
    public var description: String {
        
        "SerialStamped(serial: \(serial), value: \(describe(value)))"
    }
}

// MARK: - SerialStamped for Array

extension RemoteServices.SerialStamped: CustomStringConvertible {
    
    public var description: String {
        
        let listDescription = list.map(describe).joined(separator: ", ")
        
        return "SerialStamped(serial: \(serial), list: [\(listDescription)])"
    }
}

// MARK: - Private Helper for Concise Description

private func describe(_ value: Any) -> String {
    
    if let describable = value as? CustomStringConvertible {
        
        return String(describing: describable)
    }
    
    let mirror = Mirror(reflecting: value)
    let properties = mirror.children.map { "\($0.label ?? "\"unknown\""): \($0.value)" }
    
    return "\(type(of: value))(\(properties.joined(separator: ", ")))"
}
