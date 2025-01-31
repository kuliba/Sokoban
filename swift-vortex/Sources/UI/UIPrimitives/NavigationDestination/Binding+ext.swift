//
//  Binding+ext.swift
//
//
//  Created by Igor Malyarov on 31.01.2025.
//

import SwiftUI

public extension Binding {
    
    /// Returns a binding that prevents redundant writes when the new value is equivalent to the existing one.
    ///
    /// This helps reduce unnecessary updates in SwiftUI bindings.
    ///
    /// - Parameter isDuplicate: A closure that determines whether two values are equivalent.
    ///   If this closure returns `true`, the update is ignored.
    func removingDuplicates(
        by isDuplicate: @escaping (Value, Value) -> Bool
    ) -> Self {
        
        return .init(
            get: { self.wrappedValue },
            set: { newValue, transaction in
                
                guard !isDuplicate(self.wrappedValue, newValue)
                else { return }
                
                self.transaction(transaction).wrappedValue = newValue
            }
        )
    }
}

public extension Binding where Value: Identifiable {
    
    /// Returns a binding that prevents redundant writes when the new value has the same `id` as the existing value.
    ///
    /// This helps reduce unnecessary updates in SwiftUI bindings for `Identifiable` values.
    func removingDuplicates() -> Self {
        
        removingDuplicates { $0.id == $1.id }
    }
}

public extension Binding {
    
    /// Returns a binding that prevents redundant writes when the new value has the same `id` as the existing value.
    ///
    /// If both values are `nil`, the update is ignored.
    func removingDuplicates<T: Identifiable>() -> Self where Value == T? {
        
        removingDuplicates { lhs, rhs in
            
            switch (lhs, rhs) {
            case (nil, nil):
                return true
                
            case let (lhs?, rhs?):
                return lhs.id == rhs.id
                
            default:
                return false
            }
        }
    }
}
