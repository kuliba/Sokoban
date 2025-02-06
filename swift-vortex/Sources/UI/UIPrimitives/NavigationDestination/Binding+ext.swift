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

public extension Binding {
    
    /// Creates a new `Binding` targeting a member of `Value` specified by `keyPath`.
    ///
    /// - Parameter keyPath: A writable key path from `Value` to a specific field.
    /// - Returns: A `Binding` of the field's type, read and written through the current binding.
    @inlinable
    func field<SubValue>(
        _ keyPath: WritableKeyPath<Value, SubValue>
    ) -> Binding<SubValue> {
        
        return .init(
            get: {
                
                self.wrappedValue[keyPath: keyPath]
            },
            set: { newSubValue in
                
                self.wrappedValue[keyPath: keyPath] = newSubValue
            }
        )
    }
    
    /// Returns a binding to a read-only sub-property (via key path) of an optional root value.
    ///
    /// **Behavior**:
    /// - **`get`**: If the parent (`wrappedValue`) is `nil`, returns `nil`. Otherwise, returns the sub-property.
    /// - **`set`**:
    ///   - If the caller attempts to set the sub-value to *non-nil*, this does nothing (read-only for sub-values).
    ///   - If the caller sets the sub-value to `nil`, it resets the entire parent to `nil`.
    ///
    /// This can be useful for situations where you only want to *observe* a particular field in an optional model,
    /// but allow a special signal (`nil`) to tear down or reset the entire parent object.
    ///
    /// - Parameter keyPath: A *read-only* key path from the unwrapped root to the sub-property.
    /// - Returns: A new `Binding<SubValue?>` focusing on the sub-property, with special handling for `nil`.
    func field<Root, SubValue>(
        _ keyPath: KeyPath<Root, SubValue>
    ) -> Binding<SubValue?>
    where Value == Root? {
        
        Binding<SubValue?>(
            get: {
                
                guard let wrappedValue else { return nil }
                
                return wrappedValue[keyPath: keyPath]
            },
            set: { newValue in
                
                // If parent is already nil, there's nothing to change.
                guard self.wrappedValue != nil else { return }
                
                // If setting to nil, clear the entire parent;
                // otherwise, ignore non-nil writes (making sub-value "read-only").
                if newValue == nil {
                    
                    self.wrappedValue = nil
                }
            }
        )
    }
    
    /// Returns a "read-only" binding to an optional sub-property (`SubValue?`) of an optional root (`Root?`),
    /// while allowing the parent to be set to `nil` if this sub-value is set to `nil`.
    ///
    /// **Behavior**:
    /// - **`get`**:
    ///   - If the parent (`wrappedValue`) is `nil`, returns `nil`.
    ///   - Otherwise, returns `root[keyPath: keyPath]` (which is itself an optional).
    /// - **`set`**:
    ///   - If `wrappedValue` (the parent) is `nil`, do nothing.
    ///   - If `newValue == nil`, set the entire parent to `nil`.
    ///   - If `newValue != nil`, do nothing (making it read-only for the sub-property).
    ///
    /// This can be useful when you want to observe a nested optional field (e.g., `Root?.someOptionalProperty`)
    /// but also allow a `nil` assignment to remove the entire root object from the model.
    ///
    /// - Parameter keyPath: A **read-only** key path (cannot mutate directly) from `Root` to `SubValue?`.
    /// - Returns: A new `Binding<SubValue?>` that reflects the nested optional field, but only
    ///   allows fully setting `wrappedValue` to `nil`.
    func field<Root, SubValue>(
        _ keyPath: KeyPath<Root, SubValue?>
    ) -> Binding<SubValue?>
    where Value == Root? {
        
        Binding<SubValue?>(
            get: {
                guard let root = self.wrappedValue else {
                    return nil
                }
                return root[keyPath: keyPath]
            },
            set: { newSubValue in
                // If the parent is nil, do nothing
                guard self.wrappedValue != nil else { return }
                
                // If the new sub-value is nil, remove the entire parent
                if newSubValue == nil {
                    self.wrappedValue = nil
                }
                // If the new sub-value is non-nil, we ignore it
                // (this is "read-only" for sub-value writes)
            }
        )
    }
    
    /// Returns a binding to a sub-property (via key path) of an optional root value,
    /// automatically setting the entire parent to `nil` whenever the new sub-value is `nil`.
    ///
    /// **Behavior:**
    /// - **`get`**: If `wrappedValue` (the parent) is `nil`, returns `nil`. Otherwise returns the sub-property.
    /// - **`set`**:
    ///    - If the parent is `nil`, no update occurs (a no-op).
    ///    - If `newSubValue` is `nil`, the entire parent is set to `nil`.
    ///    - Otherwise, the sub-property is updated on the unwrapped parent.
    ///
    /// **Note**: If you want to *create* a new parent when it’s `nil`, that logic would need to go in the setter.
    /// As written, if the parent is already `nil`, it stays `nil` even if `newSubValue` is non-`nil`.
    ///
    /// - Parameter keyPath: A writable key path from the unwrapped root to the nested property.
    /// - Returns: A new `Binding<SubValue?>` focusing on the nested property.
    func field<Root, SubValue>(
        _ keyPath: WritableKeyPath<Root, SubValue>
    ) -> Binding<SubValue?>
    where Value == Root? {
        
        Binding<SubValue?>(
            get: {
                
                // If the parent is nil, sub-property is nil
                guard let wrappedValue else { return nil }
                
                return wrappedValue[keyPath: keyPath]
            },
            set: { newSubValue in
                
                // If the parent is nil, do nothing.
                guard var wrappedValue else { return }
                
                if let unwrappedSubValue = newSubValue {
                    // Update the parent’s sub-property to the new value
                    wrappedValue[keyPath: keyPath] = unwrappedSubValue
                    self.wrappedValue = wrappedValue
                    
                } else {
                    // If newSubValue is nil, set the entire parent to nil
                    self.wrappedValue = nil
                }
            }
        )
    }
}
