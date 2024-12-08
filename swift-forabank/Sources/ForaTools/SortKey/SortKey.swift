//
//  SortKey.swift
//
//
//  Created by Igor Malyarov on 08.12.2024.
//

/// Represents a sortable key derived from a string based on character priorities.
public struct SortKey {
    
    /// An array of integers representing the priority of each character in the string.
    public let priorityArray: [Int]
    
    /// An array of characters from the original string.
    public let characters: [Character]
    
    /// Initializes a `SortKey` with a given string and a priority mapping function.
    ///
    /// - Parameters:
    ///   - string: The string to generate the sort key from.
    ///   - priority: A closure that assigns a priority to each character.
    public init(
        string: String,
        priority: (Character) -> Int
    ) {
        self.priorityArray = string.map { priority($0) }
        self.characters = Array(string)
    }
}

extension SortKey: Comparable {
    
    /// Compares two `SortKey` instances to determine their ordering.
    ///
    /// - Parameters:
    ///   - lhs: The first `SortKey` to compare.
    ///   - rhs: The second `SortKey` to compare.
    /// - Returns: `true` if `lhs` is less than `rhs`, otherwise `false`.
    public static func < (lhs: SortKey, rhs: SortKey) -> Bool {
        
        let minLength = min(lhs.priorityArray.count, rhs.priorityArray.count)
        
        for i in 0..<minLength {
            
            if lhs.priorityArray[i] != rhs.priorityArray[i] {
                return lhs.priorityArray[i] < rhs.priorityArray[i]
            } else if lhs.characters[i] != rhs.characters[i] {
                return lhs.characters[i] < rhs.characters[i]
            }
        }
        
        return lhs.priorityArray.count < rhs.priorityArray.count
    }
    
    /// Determines if two `SortKey` instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: The first `SortKey` to compare.
    ///   - rhs: The second `SortKey` to compare.
    /// - Returns: `true` if both `SortKey` instances are equal, otherwise `false`.
    public static func == (lhs: SortKey, rhs: SortKey) -> Bool {
        
        return lhs.priorityArray == rhs.priorityArray
        && lhs.characters == rhs.characters
    }
}
