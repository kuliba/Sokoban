//
//  String+sortKey.swift
//  
//
//  Created by Igor Malyarov on 08.12.2024.
//

public extension String {
    
    /// Generates a `SortKey` based on the provided priority function.
    ///
    /// - Parameter priority: A closure that assigns priority to each character.
    /// - Returns: A `SortKey` instance representing the string.
    func sortKey(priority: (Character) -> Int) -> SortKey {
        
        return .init(string: self, priority: priority)
    }
}
