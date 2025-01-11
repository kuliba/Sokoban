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
    
    //                 "+7(012)-345-67-89"
    let phonePattern = "+7(___)-___-__-__"
    
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

extension String {
    
    /// Returns the masked index in the pattern for a given unmasked index.
    func maskedIndex(for unmaskedIndex: Int) -> Int? {
        // Step 1: Generate the mask map from the pattern
        let maskMapping = maskMap(pattern: self)
        
        // Step 2: Use chunkify to group non-masker values with trailing maskers
        let chunkified = maskMapping.chunkify()
        
        // Step 3: Look up the masked index for the unmasked index
        return chunkified[unmaskedIndex]
    }
}

final class MaskedIndexTests: MaskingTests {
    
    func test_phone() {
        
        //            "+7(012)-345-67-89"
        let pattern = "+7(___)-___-__-__"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 3)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 4)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 7)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 8)
        XCTAssertEqual(pattern.maskedIndex(for: 4), 9)
        XCTAssertEqual(pattern.maskedIndex(for: 5), 11)
        XCTAssertEqual(pattern.maskedIndex(for: 6), 12)
        XCTAssertEqual(pattern.maskedIndex(for: 7), 14)
        XCTAssertEqual(pattern.maskedIndex(for: 8), 15)
        XCTAssertEqual(pattern.maskedIndex(for: 9), 16)
        
        XCTAssertNil(pattern.maskedIndex(for: 10))
    }
    
    func test_shortDate() {
        
        //            "01.23"
        let pattern = "__.__"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 0)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 2)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 3)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 4)
        
        XCTAssertNil(pattern.maskedIndex(for: 4))
    }
    
    func test_longDate() {
        
        //            "01.2345"
        let pattern = "__.____"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 0)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 2)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 3)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 4)
        XCTAssertEqual(pattern.maskedIndex(for: 4), 5)
        XCTAssertEqual(pattern.maskedIndex(for: 5), 6)
        
        XCTAssertNil(pattern.maskedIndex(for: 6))
    }
    
    func test_placeholderOnly() {

        //            "0123456"
        let pattern = "NNN_NNN"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 0)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 1)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 2)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 3)
        XCTAssertEqual(pattern.maskedIndex(for: 4), 4)
        XCTAssertEqual(pattern.maskedIndex(for: 5), 5)
        XCTAssertEqual(pattern.maskedIndex(for: 5), 5)
        XCTAssertEqual(pattern.maskedIndex(for: 6), 6)
        
        XCTAssertNil(pattern.maskedIndex(for: 7))
    }
    
    func test_staticOnly_shouldIncludeAllStaticChars() {
        
        let pattern = "+7 ( ) -"
        
        XCTAssertNil(pattern.maskedIndex(for: 0))
    }
    
    func test_staticAndPlaceholderMix() {
        
        //            "AB012C"
        let pattern = "AB_N_C"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 2)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 3)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 5)
        
        XCTAssertNil(pattern.maskedIndex(for: 4))
    }
    
    func test_edgeCases() {
        
        //            "(01)-23"
        let pattern = "(__)-__"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 1)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 4)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 5)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 6)
        
        XCTAssertNil(pattern.maskedIndex(for: 4))
    }
    
    func test_alternatingStaticAndPlaceholder() {
        
        //            "A012B345C67"
        let pattern = "A_N_B_N_C_N"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 1)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 2)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 4)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 5)
        XCTAssertEqual(pattern.maskedIndex(for: 4), 6)
        XCTAssertEqual(pattern.maskedIndex(for: 5), 8)
        XCTAssertEqual(pattern.maskedIndex(for: 6), 9)
        XCTAssertEqual(pattern.maskedIndex(for: 7), 10)
        
        XCTAssertNil(pattern.maskedIndex(for: 8))
    }
}
