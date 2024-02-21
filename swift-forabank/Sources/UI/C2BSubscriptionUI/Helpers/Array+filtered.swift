//
//  Array+filtered.swift
//  
//
//  Created by Igor Malyarov on 11.02.2024.
//

import Foundation

extension Array {
    
    /// Returns filtered array elements. Empty filtering text has no effect.
    /// - Parameters:
    ///   - text: Text to filter by. It has no effect if empty.
    ///   - keyPath: A keyPath to use for comparison.
    /// - Returns: Array of filtered elements.
    func filtered(
        with text: String,
        keyPath: KeyPath<Element, String>
    ) -> Self {
        
        guard !text.isEmpty else { return self }
        
        return filter {
            
            $0[keyPath: keyPath]
                .localizedCaseInsensitiveContains(text)
        }
    }
}
