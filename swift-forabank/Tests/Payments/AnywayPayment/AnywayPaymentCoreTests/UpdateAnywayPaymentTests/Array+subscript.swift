//
//  Array+subscript.swift
//
//
//  Created by Igor Malyarov on 05.04.2024.
//

extension Array where Element: Identifiable {
    
    /// Accesses or modifies the element with the specified identifier.
    ///
    /// When you access the subscript with an identifier, this method returns the first element in the array with the matching identifier, or `nil` if no such element exists.
    ///
    /// When you set the subscript, you can provide an optional `Element`. If an element with the given identifier exists and you provide a non-nil value, the method updates the element. If you provide `nil`, the method removes the element from the array.
    ///
    /// - Parameter id: An identifier of the type `Element.ID`.
    ///
    /// - Complexity: O(n), where n is the length of the array.
    subscript(id id: Element.ID) -> Element? {
        
        get {
            guard let element = first(where: { $0.id == id })
            else { return nil }
            
            return element
        }
        
        set {
            guard let index = firstIndex(where: { $0.id == id })
            else { return }
            
            if let newValue {
                if newValue.id == id {
                    self[index] = newValue
                }
            } else {
                remove(at: index)
            }
        }
    }
}
