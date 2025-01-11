//
//  String+maskedIndex.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

extension String {
    
    /// Returns the index in the masked pattern that corresponds to a given unmasked index.
    ///
    /// - Parameter unmaskedIndex: The index of the unmasked input value.
    /// - Returns: The corresponding index in the masked pattern, or `nil` if not found.
    @inlinable
    public func maskedIndex(
        for unmaskedIndex: Int
    ) -> Int? {
        
        // Step 1: Generate the mask map from the pattern
        let maskMapping = generateMaskMap()
        
        // Step 2: Use chunkify to group non-masker values with trailing maskers
        let chunkified = maskMapping.chunkify()
        
        // Step 3: Look up the masked index for the unmasked index
        return chunkified[unmaskedIndex]
    }
    
    /// Generates a mapping of the pattern where placeholders are mapped to their unmasked indices,
    /// and static characters are marked with `-1`.
    ///
    /// - Returns: An array where unmasked characters are mapped to their indices,
    ///            and static characters are marked with `-1`.
    @usableFromInline
    func generateMaskMap() -> [Int] {
        
        var mapping = [Int]()
        var unmaskedIndex = 0
        
        for char in self {
            
            if char.isPlaceholder {
                mapping.append(unmaskedIndex)
                unmaskedIndex += 1
            } else {
                mapping.append(-1)
            }
        }
        
        return mapping
    }
}

extension Array where Element == Int {
    
    /// Groups non-masker values with their trailing maskers into chunks.
    ///
    /// - Parameter masker: The value representing masked elements (default is `-1`).
    /// - Returns: A dictionary where the key is a non-masker value, and the value is the last index in its chunk.
    @usableFromInline
    func chunkify(
        masker: Int = .maskPlaceholder
    ) -> [Int: Int] {
        
        guard !isEmpty else { return [:] }
        
        var result: [Int: Int] = [:]
        var i = 0
        let n = count
        
        // 1) Skip leading maskers
        while i < n, self[i] == masker {
            i += 1
        }
        
        while i < n {
            
            // This is the "head" non-masker
            let headValue = self[i]
            let headIndex = i
            i += 1
            
            // Now gather trailing maskers until we hit another non-masker or end
            while i < n, self[i] == masker {
                i += 1
            }
            
            // The chunk ends just before next non-masker => last index = i-1
            // If there were no trailing -1, then i-1 == headIndex
            let lastIndex = (i - 1 >= headIndex) ? (i - 1) : headIndex
            
            // Save `headValue` as key, value: lastIndex
            result[headValue] = lastIndex
        }
        
        return result
    }
}

extension Int {
    
    /// The default value representing a masked character in the pattern.
    @usableFromInline
    static let maskPlaceholder = -1
}
