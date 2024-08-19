//
//  Array+assignIDs.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public extension Array where Element: Hashable {
    
    /// Assigns identifiers to the given items by reusing available IDs from the array and generating new ones as needed.
    ///
    /// - Parameters:
    ///   - items: An array of items to be identified.
    ///   - makeID: A closure that generates a new ID when required.
    /// - Returns: An array of `Identified` objects, where each item is associated with either a reused ID or a newly generated one.
    func assignIDs<T>(
        _ items: [T],
        _ makeID: () -> Element
    ) -> [Identified<Element, T>] {
        
        let head = zip(self, items)
        let tail = items.dropFirst(head.map(\.0).count)
        
        return head.map { .init(id: $0, element: $1) } + tail.map { .init(id: makeID(), element: $0) }
    }
}
