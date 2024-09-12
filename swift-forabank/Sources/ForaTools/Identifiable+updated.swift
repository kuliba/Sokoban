//
//  Identifiable+updated.swift
//  
//
//  Created by Igor Malyarov on 12.09.2024.
//

public extension Array where Element: Identifiable {
    
    /// Updates the array by replacing elements that have the same `id` with those from the `update` array,
    /// and appending new elements from the `update` array if they don't exist in the original array.
    ///
    /// - Parameter update: An array of updated elements, where each element must conform to the `Identifiable` protocol.
    /// - Returns: A tuple containing the updated array and a `Bool` indicating whether any updates were made.
    ///
    /// If the `update` array is empty, this function returns the original array along with `false` to indicate no changes.
    /// If no elements in the original array share the same `id` with those in the `update`, the function appends the `update` elements and returns `true`.
    /// Otherwise, elements in the original array that share the same `id` as those in the `update` are replaced, and new elements are appended.
    func updated(
        with update: Self
    ) -> (Self, Bool) {
        
        // Return early if the update array is empty
        guard !update.isEmpty else { return (self, false) }
        
        // Collect all IDs in the update array
        let idsInUpdate = Set(update.map(\.id))
        
        // Short-circuit if no elements in the original array share IDs with the update
        let commonIds = Set(self.map(\.id)).intersection(idsInUpdate)
        if commonIds.isEmpty {
            return (self + update, true)
        }
        
        // Create a copy of the original array and remove elements that have matching IDs in the update array
        var copy = self
        copy.removeAll(where: { idsInUpdate.contains($0.id) })
        
        // Append the update elements to the filtered copy
        return (copy + update, true)
    }
}

