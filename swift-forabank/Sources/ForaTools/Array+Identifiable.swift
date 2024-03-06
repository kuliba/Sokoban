//
//  Array+Identifiable.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

public extension Array where Element: Identifiable {
    
    /// `Get`: return element with given `id` or nil if no such Element.
    /// `Set`:
    /// Replace the existing element if newValue is not nil
    /// If newValue is nil, remove the element
    /// If the ID is not found and newValue is not nil, append it
    /// If the ID is not found and newValue is nil, do nothing
    subscript(id id: Element.ID) -> Element? {
        
        get { first { $0.id == id }}
        
        set(newValue) {
            
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            } else {
                if let newValue {
                    append(newValue)
                }
            }
        }
    }
}

