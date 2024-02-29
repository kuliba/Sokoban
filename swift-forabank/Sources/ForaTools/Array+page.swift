//
//  Array+page.swift
//
//
//  Created by Igor Malyarov on 29.02.2024.
//

public extension Array where Element: Identifiable {
    
    /// Return a slice of the array starting from the element with given `id`, up to the specified `pageSize`.
    /// If the element with the given ID is not found, return an empty array.
    func page(
        startingAt id: Element.ID,
        pageSize: Int
    ) -> Self {
        
        guard let startIndex = self.firstIndex(where: { $0.id == id })
        else { return [] }
        
        let endIndex = index(startIndex, offsetBy: pageSize, limitedBy: count) ?? count
        return .init(self[startIndex..<endIndex])
    }
}
