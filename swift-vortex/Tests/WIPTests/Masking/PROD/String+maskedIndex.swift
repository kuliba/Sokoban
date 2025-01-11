//
//  String+maskedIndex.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

extension String {
    
    /// Returns the masked index in the pattern for a given unmasked index.
    func maskedIndex(
        for unmaskedIndex: Int
    ) -> Int? {
        
        // Step 1: Generate the mask map from the pattern
        let maskMapping = maskMap()
        
        // Step 2: Use chunkify to group non-masker values with trailing maskers
        let chunkified = maskMapping.chunkify()
        
        // Step 3: Look up the masked index for the unmasked index
        return chunkified[unmaskedIndex]
    }
    
    // Step 1: Build the initial map
    func maskMap() -> [Int] {
        
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
    
    func chunkify(
        masker: Int = .masker
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

private extension Int {
    
    static let masker = -1
}
