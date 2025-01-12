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
        
        Array(self).generateMaskMap()
    }
}

extension Array where Element == Character {

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
        while i < n, self[i] == masker { i += 1 }
        
        while i < n {
            
            // This is the "head" non-masker
            let headValue = self[i]
            let headIndex = i
            i += 1
            
            // Now gather trailing maskers until we hit another non-masker or end
            while i < n, self[i] == masker { i += 1 }
            
            // The chunk ends just before next non-masker => last index = i-1
            // If there were no trailing -1, then i-1 == headIndex
            let lastIndex = (i - 1 >= headIndex) ? (i - 1) : headIndex
            
            // Save `headValue` as key, value: lastIndex
            result[headValue] = lastIndex
        }
        
        return result
    }
}

extension Array where Element == Int {
    
    /// Groups placeholders (≥0) with trailing `-1` static characters until the next placeholder.
    ///
    /// Example for pattern "+7(___)-___-__-__" => generateMaskMap():
    ///
    ///   indices: 0 1 2 3 4 5 6 7  8 9 10 11 12 13 14 15 16 17
    ///   values: -1-1-1 0 1 2 -1-1  3 4  5  -1  6  7  -1  8  9
    ///
    /// Produces chunks:
    ///
    ///   0: (3, 4)     // single `_` at index 3
    ///   1: (4, 7)     // placeholders at indices 4,5 + trailing -1 at 6
    ///   2: (7, 8)     // single `-1` at index 7 + next placeholder is 3 at index 8
    ///   3: (8, 9)     // single `_` at index 8
    ///   4: (9, 11)    // placeholders at indices 9,10 + trailing -1 at 11
    ///   5: (11, 12)   // single -1 at index 11 + next placeholder is 6 at index 12
    ///   6: (12, 14)   // placeholders at indices 12,13 + trailing -1 at 14
    ///   7: (14, 15)   // single -1 at index 14 + next placeholder is 8 at index 15
    ///   8: (15, 16)   // single `_` at index 15
    ///   9: (16, 17)   // placeholders at index 16 + next placeholder or end is 17
    ///
    /// This ensures placeholders are always followed by static chars (if any) in one chunk,
    /// until we hit the next placeholder or end of array, matching the final expected output.
    ///
    @usableFromInline
    func chunkify2() -> [Int: (lower: Int, upper: Int)] {
        
        var result: [Int: (lower: Int, upper: Int)] = [:]
        
        // We'll track the next unmasked index to appear
        var nextKey = 0
        let n = count
        var i = 0
        
        // 1) Skip leading -1
        while i < n, self[i] == -1 { i += 1 }
        
        while i < n {
            let placeholderValue = self[i]
            
            if placeholderValue == -1 {
                i += 1
                continue
            }
            
            // Start chunk at i
            let start = i
            
            // Move forward exactly one placeholder
            i += 1
            
            // Gather trailing -1 until next placeholder
            while i < n, self[i] == -1 {
                i += 1
            }
            
            let end = i
            result[nextKey] = (start, end)
            nextKey += 1
        }
        
        return result
    }
}

extension Int {
    
    /// The default value representing a masked character in the pattern.
    @usableFromInline
    static let maskPlaceholder = -1
}
