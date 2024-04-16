//
//  Array+subscript.swift
//
//
//  Created by Igor Malyarov on 05.04.2024.
//

extension Array where Element: Identifiable {
    
    /// Accesses, modifies, or appends an element with the specified identifier.
    ///
    /// When accessing the subscript with an identifier, it returns the first element in the array with the matching identifier, or `nil` if no such element exists.
    ///
    /// When setting the subscript:
    /// - If an element with the given identifier exists:
    ///   - If a non-nil value is provided, the method updates the element.
    ///   - If `nil` is provided, the method removes the element.
    /// - If no element with the given identifier exists:
    ///   - If a non-nil value is provided, the method appends the new element to the array.
    ///   - If `nil` is provided, no action is taken.
    ///
    /// - Parameter id: An identifier of the type `Element.ID`.
    ///
    /// - Complexity: O(n), where n is the length of the array.
    public subscript(id id: Element.ID) -> Element? {
        
        get {
            guard let element = first(where: { $0.id == id })
            else { return nil }
            
            return element
        }
        
        set {
            guard let index = firstIndex(where: { $0.id == id })
            else {
                if let newValue { append(newValue) }
                return
            }
            
            if let newValue {
                if newValue.id == id {
                    self[index] = newValue
                } else {
                    append(newValue)
                }
            } else {
                remove(at: index)
            }
        }
    }
}
