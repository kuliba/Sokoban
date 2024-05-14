//
//  ArraySlice+page.swift
//
//
//  Created by Igor Malyarov on 14.05.2024.
//

import Foundation

public extension ArraySlice where Element: Identifiable {
    
    /// Return a slice of the array starting from the element with given `id`, up to the specified `pageSize`.
    /// If the element with the given ID is not found, return an empty array.
    func page(
        startingAt id: Element.ID,
        pageSize: Int
    ) -> Self {
        
        guard let startIndex = self.firstIndex(where: { $0.id == id })
        else { return [] }
        
        let endIndex = index(startIndex, offsetBy: pageSize, limitedBy: count) ?? count
        return self[startIndex..<endIndex]
    }
    
    /// Return a slice of the array starting `after` the element with given `id`, up to the specified `pageSize`.
    /// If the element with the given ID is not found, return an empty array.
    func page(
        startingAfter id: Element.ID,
        pageSize: Int
    ) -> Self {
        
        guard let startIndex = self.firstIndex(where: { $0.id == id })
        else { return [] }
        
        let nextIndex = index(startIndex, offsetBy: 1, limitedBy: count) ?? count
        let endIndex = index(nextIndex, offsetBy: pageSize, limitedBy: count) ?? count
        return self[nextIndex..<endIndex]
    }
}
