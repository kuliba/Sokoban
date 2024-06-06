//
//  Array+uniqueValues.swift
//
//
//  Created by Igor Malyarov on 04.06.2024.
//

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
