//
//  Validatable.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Protocol for objects that can be validated.
public protocol Validatable {
    
    /// Whether the object is valid.
    var isValid: Bool { get }
}
