//
//  Dictionary+Identifiable.swift
//
//
//  Created by Igor Malyarov on 23.06.2024.
//

public extension Dictionary
where Value: Identifiable, Key == Value.ID {
    
    /// Initialises a dictionary from an array of identifiable elements.
    ///
    /// - Parameters:
    ///   - array: An array of elements conforming to `Identifiable`.
    ///   - useLast: A Boolean value indicating whether to use the last occurrence of each key. Defaults to `true`. If `true`, the last duplicate will overwrite previous ones. If `false`, the first duplicate will be used.
    init(array: [Value],useLast: Bool = true) {
        
        self.init(array.map { ($0.id, $0) }) { useLast ? $1 : $0 }
    }
}
