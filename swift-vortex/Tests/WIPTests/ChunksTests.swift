//
//  ChunksTests.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

extension Array where Element == Int {
    
    func chunkify(masker: Int = .masker) -> [Int: Int] {
        
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

import XCTest

final class ChunksTests: MaskingTests {
    
    func test() {
        
        assert([], [])
        assert([1], [(1, 0)])
        
        assert([0, 1], [(0, 0), (1, 1)])
        assert([0, 1, -1], [(0, 0), (1, 2)])
        assert([-1, 1, -1], [(1, 2)])
        
        assert([-1, -1, -1], [])
        
        assert([1, -1, 2], [(1, 1), (2, 2)])
        assert([-1, -1, -1, 0], [(0, 3)])
        assert([-1, -1, -1, 2], [(2, 3)])
        
        assert([-1, 1, 2, 3], [(1, 1), (2, 2), (3, 3)])
        assert([1, 2, 3, -1, -1], [(1, 0), (2, 1), (3, 4)])
        
        assert([-1, -1, -1, 0, -1], [(0, 4)])
        assert([-1, -1, -1, 0, 1], [(0, 3), (1, 4)])
        
        assert([1, -1, 2, -1, 3, -1], [(1, 1), (2, 3), (3, 5)])
        assert([1, 2, 3], [(1, 0), (2, 1), (3, 2)])
        
        assert(input, [
            (0, 3),
            (1, 6),
            (2, 7),
            (3, 8),
            (4, 12),
            (5, 13),
            (6, 15),
            (7, 16),
            (8, 17),
            (9, 18),
        ])
        
        assert(phone, [
            (0, 3),
            (1, 4),
            (2, 7),
            (3, 8),
            (4, 9),
            (5, 11),
            (6, 12),
            (7, 14),
            (8, 15),
            (9, 16),
        ])
    }
    
    // MARK: - Helpers
    
    private let input = [
        -1, -1, -1,     // skip
         0,             // 3
         1, -1, -1,     // 6
         2,             // 7
         3,             // 8
         4, -1, -1, -1, // 12
         5,             // 13
         6, -1,         // 15
         7,             // 16
         8,             // 17
         9              // 18
    ]
    
    private func chunkify(_ input: [Int]) -> [Pair] {
        
        input.chunkify().map { .init($0.key, $0.value) }.sorted(by: \.key)
    }
    
    private struct Pair: Equatable {
        
        let key: Int
        let value: Int
        
        init(
            _ key: Int,
            _ value: Int
        ) {
            self.key = key
            self.value = value
        }
    }
    
    private func assert(
        _ input: [Int],
        _ expected: [(Int, Int)],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let result = chunkify(input)
        let readable = result.map { ($0.key, $0.value) }.sorted(by: { $0.0 < $1.0 })
        let mapped = expected.map { Pair($0, $1) }.sorted(by: \.key)
        
        XCTAssertNoDiff(
            result,
            mapped,
            "Expected \(input) to chunkify to \(expected), but got \(readable) instead.",
            file: file,
            line: line
        )
    }
}

extension Sequence {
    
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>
    ) -> [Self.Element] {
        
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}

// Step 1: Build the initial map
func maskMap(pattern: String) -> [Int] {
    
    var mapping = [Int]()
    var unmaskedIndex = 0
    
    for char in pattern {
        if char.isPlaceholder {
            mapping.append(unmaskedIndex)
            unmaskedIndex += 1
        } else {
            mapping.append(-1)
        }
    }
    
    return mapping
}

final class MapTests: MaskingTests {
    
    func testMap() {
        
        let pattern = "+7(___)-___-__-__"
        let mapping = maskMap(pattern: pattern)
        
        XCTAssertEqual(mapping, phone)
    }
}

class MaskingTests: XCTestCase {
    
    let phone = [
        -1, -1, -1,     // skip
         0,             // 3
         1,             // 4
         2, -1, -1,     // 7
         3,             // 8
         4,             // 9
         5, -1,         // 11
         6,             // 12
         7, -1,         // 14
         8,             // 15
         9              // 16
    ]
}
