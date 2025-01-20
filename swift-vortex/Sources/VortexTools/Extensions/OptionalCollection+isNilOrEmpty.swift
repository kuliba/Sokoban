//
//  OptionalCollection+isNilOrEmpty.swift
//  
//
//  Created by Igor Malyarov on 17.01.2025.
//

public extension Optional where Wrapped: Collection {
    
    /// Returns `true` if the collection is `nil` or empty.
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}
