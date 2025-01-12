//
//  MaskUnmaskRangeTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 11.01.2025.
//

@testable import TextFieldModel
import XCTest

final class MaskUnmaskRangeTests: XCTestCase {
    
    func test_unmaskRange_negativeOutOfBounds() {
        
        assertUnmasked(-10..<(-1), with: "+7(___)-___-__-__", is: 0..<0)
    }
    
    func test_unmaskRange_emptyMask() {
        
        assertUnmasked(0..<5,  with: "", is: 0..<5)
        assertUnmasked(0..<0,  with: "", is: 0..<0)
        assertUnmasked(5..<10, with: "", is: 5..<10)
    }
    
    func test_unmaskRange_phone() {
        
        //     0..<18 "12345678901234567
        //     0..<18 "+7(123)-456-78-90", is: 0..<10
        let pattern = "+7(___)-___-__-__"
        
        assertUnmasked(0..<0,   with: pattern, is: 0..<0)
        assertUnmasked(0..<2,   with: pattern, is: 0..<0)
        assertUnmasked(0..<3,   with: pattern, is: 0..<0)
        assertUnmasked(0..<5,   with: pattern, is: 0..<2)
        assertUnmasked(0..<18,  with: pattern, is: 0..<10)
        assertUnmasked(0..<50,  with: pattern, is: 0..<10)
        assertUnmasked(0..<100, with: pattern, is: 0..<10)
        assertUnmasked(2..<5,   with: pattern, is: 0..<2)
        assertUnmasked(2..<8,   with: pattern, is: 0..<3)
        assertUnmasked(3..<4,   with: pattern, is: 0..<1)
        assertUnmasked(3..<5,   with: pattern, is: 0..<2)
        assertUnmasked(4..<7,   with: pattern, is: 1..<3)
        assertUnmasked(4..<8,   with: pattern, is: 1..<3)
        assertUnmasked(5..<10,  with: pattern, is: 2..<5)
        assertUnmasked(5..<50,  with: pattern, is: 2..<10)
        assertUnmasked(6..<9,   with: pattern, is: 3..<4)
        assertUnmasked(7..<8,   with: pattern, is: 3..<3)
        assertUnmasked(8..<15,  with: pattern, is: 3..<8)
        assertUnmasked(9..<13,  with: pattern, is: 4..<7)
        assertUnmasked(12..<13, with: pattern, is: 6..<7)
        assertUnmasked(15..<17, with: pattern, is: 8..<10)
        assertUnmasked(16..<18, with: pattern, is: 9..<10)
    }
    
    func test_unmaskRange_placeholderOnly() {
        
        // "NNNNN" → max unmasked length = 5
        assertUnmasked(0..<5, with:  "NNNNN", is: 0..<5)
        assertUnmasked(2..<4, with:  "NNNNN", is: 2..<4)
        assertUnmasked(0..<0, with:  "NNNNN", is: 0..<0)
        assertUnmasked(4..<10, with: "NNNNN", is: 4..<5)
    }
    
    func test_unmaskRange_staticOnly() {
        
        // "+7 ( ) -" → no placeholders
        assertUnmasked(0..<8, with: "+7 ( ) -", is: 0..<0)
        assertUnmasked(2..<4, with: "+7 ( ) -", is: 0..<0)
        assertUnmasked(0..<0, with: "+7 ( ) -", is: 0..<0)
    }
    
    func test_unmaskRange_staticAndPlaceholderMix() {
        
        //             0..<6         "123456" is:
        //             0..<6         "AB123C" is:
        //             0..<6         "AB_N_C" is:
        assertUnmasked(0..<6, with: "AB_N_C", is: 0..<3)
        assertUnmasked(3..<4, with: "AB_N_C", is: 1..<2)
        assertUnmasked(1..<5, with: "AB_N_C", is: 0..<3)
    }
    
    func test_unmaskRange_edgeCases() {
        
        //             0..<8          "1234567"
        //             0..<8          "(12)-34"
        //             0..<8          "(__)-__"
        assertUnmasked(-5..<2,  with: "(__)-__", is: 0..<1)
        assertUnmasked(0..<2,   with: "(__)-__", is: 0..<1)
        assertUnmasked(0..<8,   with: "(__)-__", is: 0..<4)
        assertUnmasked(1..<4,   with: "(__)-__", is: 0..<2)
        assertUnmasked(3..<100, with: "(__)-__", is: 2..<4)
        assertUnmasked(5..<5,   with: "(__)-__", is: 2..<2)
        assertUnmasked(6..<6,   with: "(__)-__", is: 3..<3)
    }
    
    func test_unmaskRange_staticEdges() {
        
        //                          "+N-N+"
        assertUnmasked(0..<1, with: "+N-N+", is: 0..<0)
        assertUnmasked(1..<2, with: "+N-N+", is: 0..<1)
        assertUnmasked(4..<5, with: "+N-N+", is: 2..<2)
        assertUnmasked(0..<5, with: "+N-N+", is: 0..<2)
    }
    
    func test_unmaskRange_overlappingStaticAndPlaceholder() {
        
        //                          "+7(__)-__"
        assertUnmasked(2..<6, with: "+7(__)-__", is: 0..<2)
        assertUnmasked(5..<9, with: "+7(__)-__", is: 2..<4)
    }
    
    func test_unmaskRange_singlePlaceholder() {
        
        assertUnmasked(0..<1, with: "N", is: 0..<1)
        assertUnmasked(0..<0, with: "N", is: 0..<0)
        assertUnmasked(-5..<2, with: "N", is: 0..<1)
    }
    
    func test_unmaskRange_alternatingStaticAndPlaceholder() {
        
        //                           "12345678901"
        //                           "A123B456C78"
        assertUnmasked(0..<11, with: "A_N_B_N_C_N", is: 0..<8)
        assertUnmasked(1..<5,  with: "A_N_B_N_C_N", is: 0..<3)
        assertUnmasked(2..<3,  with: "A_N_B_N_C_N", is: 1..<2)
    }
    
    func test_unmaskRange_noPlaceholders() {
        
        assertUnmasked(0..<7,   with: "ABC-DEF", is: 0..<0)
        assertUnmasked(0..<100, with: "ABC-DEF", is: 0..<0)
        assertUnmasked(3..<5,   with: "ABC-DEF", is: 0..<0)
    }
    
    func test_unmaskRange_consecutivePlaceholders() {
        
        //                          "NNN-___-NN"
        assertUnmasked(0..<3, with: "NNN-___-NN", is: 0..<3)
        assertUnmasked(4..<7, with: "NNN-___-NN", is: 3..<6)
        assertUnmasked(7..<9, with: "NNN-___-NN", is: 6..<7)
    }
    
    // MARK: - Helpers
    
    private func assertUnmasked(
        _ range: Range<Int>,
        with pattern: String,
        is expected: Range<Int>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let mask = Mask(pattern: pattern)
        let unmasked = mask.unmask(range.toNSRange())
        
        XCTAssertNoDiff(
            unmasked,
            expected.toNSRange(),
            "Expected \(expected) range, but got \(unmasked) instead.",
            file: file,
            line: line
        )
    }
}

extension Range where Bound == Int {
    
    func toNSRange() -> NSRange {
        
        return NSRange(location: lowerBound, length: upperBound - lowerBound)
    }
}
