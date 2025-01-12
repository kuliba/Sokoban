//
//  String+maskedIndex.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

extension String {
    
    /// Returns the masked index in the pattern that corresponds to a given unmasked index.
    ///
    /// - Parameter unmaskedIndex: The unmasked text index (number of typed characters).
    /// - Returns: The masked text index if found; otherwise `nil`.
    @inlinable
    public func maskedIndex(
        for unmaskedIndex: Int
    ) -> Int? {
        
        // 1) Generate placeholder/static mapping
        let maskMapping = generateMaskMap()
        
        // 2) chunkify groups static elements with preceding placeholders
        let chunkified = maskMapping.chunkify()
        
        // 3) Direct lookup of the masked index for `unmaskedIndex`
        return chunkified[unmaskedIndex]
    }
    
    /// Generates a mapping for each character in `self` where placeholders are assigned
    /// an unmasked index and static characters receive `-1`.
    @usableFromInline
    func generateMaskMap() -> [Int] {
        
        Array(self).generateMaskMap()
    }
}

extension Array where Element == Character {
    
    /// Produces an array representing how each character in `self` maps to unmasked indices:
    /// placeholders map to incrementing indices, static chars map to `-1`.
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
    
    /// Groups non-masker (≥0) values with trailing maskers (`-1`) into chunks.
    /// This is primarily used by `.maskedIndex(for:)` logic to find the final masked index.
    @usableFromInline
    func chunkify(
        masker: Int = .maskPlaceholder
    ) -> [Int: Int] {
        
        guard !isEmpty else { return [:] }
        
        var result: [Int: Int] = [:]
        var i = 0
        let n = count
        
        // Skip leading maskers
        while i < n, self[i] == masker { i += 1 }
        
        while i < n {
            
            // This is a "head" non-masker
            let headValue = self[i]
            let headIndex = i
            i += 1
            
            // Gather trailing maskers up to the next placeholder or end
            while i < n, self[i] == masker { i += 1 }
            
            // The chunk ends just before the next non-masker => i-1
            let lastIndex = (i - 1 >= headIndex) ? (i - 1) : headIndex
            
            // Save final index
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
    /// - Warning: Not currently used in the Mask workflow, but helpful for specialized chunk grouping.
    @usableFromInline
    func chunkify2() -> [Int: (lower: Int, upper: Int)] {
        
        var result: [Int: (lower: Int, upper: Int)] = [:]
        
        var nextKey = 0
        let n = count
        var i = 0
        
        // 1) Skip leading `-1`
        while i < n, self[i] == -1 { i += 1 }
        
        while i < n {
            let placeholderValue = self[i]
            
            if placeholderValue == -1 {
                i += 1
                continue
            }
            
            let start = i
            
            // Move forward for exactly one placeholder, then gather trailing -1.
            i += 1
            while i < n, self[i] == -1 { i += 1 }
            
            let end = i
            result[nextKey] = (start, end)
            nextKey += 1
        }
        
        return result
    }
}

extension Int {
    
    /// Default marker for static (masked) characters in the pattern.
    @usableFromInline
    static let maskPlaceholder = -1
}
