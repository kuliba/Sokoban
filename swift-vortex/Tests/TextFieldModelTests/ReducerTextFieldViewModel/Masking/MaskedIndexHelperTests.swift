//
//  MaskedIndexHelperTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 11.01.2025.
//

@testable import TextFieldModel
import XCTest

final class MaskedIndexHelperTests: XCTestCase {
    
    // MARK: - chunkify
    
    func test_chunkify() {
        
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

    // MARK: - generateMaskMap
    
    func test_maskMap_phone() {
        
        let pattern = "+7(___)-___-__-__"
        
        XCTAssertEqual(pattern.generateMaskMap(), phone)
    }
    
    func test_maskMap_shortDate() {
        
        //            "01.23"
        let pattern = "__.__"
        
        XCTAssertEqual(pattern.generateMaskMap(), [0, 1, -1, 2, 3])
    }
    
    func test_maskMap_longDate() {
        
        //            "01.2345"
        let pattern = "__.____"
        
        XCTAssertEqual(pattern.generateMaskMap(), [0, 1, -1, 2, 3, 4, 5])
    }

    // MARK: - Helpers
    
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

#warning("from VortexTools")
private extension Sequence {
    
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>
    ) -> [Self.Element] {
        
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
