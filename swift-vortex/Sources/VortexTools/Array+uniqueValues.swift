//
//  Array+uniqueValues.swift
//
//
//  Created by Igor Malyarov on 04.06.2024.
//

public extension Array {
    
    /// Returns an array with unique values based on a specified key path, optionally keeping the last occurrence of each element.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property to use for uniqueness.
    ///   - useLast: A Boolean value that determines whether to keep the last occurrence of each unique element.
    /// - Returns: An array of unique values based on the specified key path.
    func uniqueValues<Value: Hashable>(
        by keyPath: KeyPath<Element, Value>,
        useLast: Bool = true
    ) -> [Element] {
        
        var seen = Set<Value>()
        
        if useLast {
            return self.reversed().filter { seen.insert($0[keyPath: keyPath]).inserted }.reversed()
        } else {
            return self.filter { seen.insert($0[keyPath: keyPath]).inserted }
        }
    }
}

public extension Array where Element: Hashable {
    
    /// Returns an array with unique values, optionally keeping the last occurrence of each element.
    ///
    /// - Parameter useLast: A Boolean value that determines whether to keep the last occurrence of each unique element.
    /// - Returns: An array of unique values.
    func uniqueValues(
        useLast: Bool = true
    ) -> [Element] {
        
        var seen = Set<Element>()
        
        if useLast {
            return self.reversed().filter { seen.insert($0).inserted }.reversed()
        } else {
            return self.filter { seen.insert($0).inserted }
        }
    }
}

public extension Array where Element: Identifiable {
    
    /// Returns an array with unique values based on the `id` property, optionally keeping the last occurrence of each element.
    ///
    /// - Parameter useLast: A Boolean value that determines whether to keep the last occurrence of each unique element.
    /// - Returns: An array of unique values based on the `id` property.
    func uniqueValues(
        useLast: Bool = true
    ) -> [Element] {
        
        var seen = Set<Element.ID>()
        
        if useLast {
            return self.reversed().filter { seen.insert($0.id).inserted }.reversed()
        } else {
            return self.filter { seen.insert($0.id).inserted }
        }
    }
}
