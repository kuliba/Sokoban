//
//  MaskUnmaskRangeTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 11.01.2025.
//

@testable import TextFieldModel
import XCTest

final class MaskUnmaskRangeTests: XCTestCase {
    
    func test_unmaskRange_emptyMask() {
        
        assertUnmasked(.init(0, 5),  with: "", is: .init(0, 5))
        assertUnmasked(.init(0, 0),  with: "", is: .init(0, 0))
        assertUnmasked(.init(5, 10), with: "", is: .init(5, 10))
    }
    
    func test_unmaskRange_phone() {
        
        //     0..<17 "01234567890123456
        //     0..<17 "+7(012)-345-67-89", is: 0..<10
        let pattern = "+7(___)-___-__-__"
        
        assertUnmasked(.init(0, 0),   with: pattern, is: .init(0, 0))
        assertUnmasked(.init(0, 5),   with: pattern, is: .init(0, 2))
        assertUnmasked(.init(0, 18),  with: pattern, is: .init(0, 10))
        assertUnmasked(.init(0, 50),  with: pattern, is: .init(0, 10))
        assertUnmasked(.init(0, 100), with: pattern, is: .init(0, 10))
    }
    
    func test_unmaskRange_shortDate() {
        
        //            "01234"
        //            "01.23"
        let pattern = "__.__"
        
        assertUnmasked(.init(0, 0), with: pattern, is: .init(0, 0))
        assertUnmasked(.init(1, 0), with: pattern, is: .init(1, 0))
        assertUnmasked(.init(3, 0), with: pattern, is: .init(2, 0))

        assertUnmasked(.init(0, 3), with: pattern, is: .init(0, 2))
        assertUnmasked(.init(0, 5), with: pattern, is: .init(0, 4))
    }
    
    func test_unmaskRange_placeholderOnly() {
        
        // "NNNNN" → max unmasked length = 5
        assertUnmasked(.init(0, 5), with:  "NNNNN", is: .init(0, 5))
        assertUnmasked(.init(0, 0), with:  "NNNNN", is: .init(0, 0))
    }
    
    func test_unmaskRange_staticOnly() {
        
        // "+7 ( ) -" → no placeholders
        assertUnmasked(.init(0, 0), with: "+7 ( ) -", is: .init(0, 0))
    }
    
    func test_unmaskRange_staticAndPlaceholderMix() {
        
        //             0..<6         "123456" is:
        //             0..<6         "AB123C" is:
        //             0..<6         "AB_N_C" is:
        assertUnmasked(.init(0, 6), with: "AB_N_C", is: .init(0, 3))
        assertUnmasked(.init(3, 4), with: "AB_N_C", is: .init(1, 2))
        assertUnmasked(.init(1, 5), with: "AB_N_C", is: .init(0, 3))
    }
    
    func test_unmaskRange_edgeCases() {
        
        //             0..<8          "1234567"
        //             0..<8          "(12)-34"
        //             0..<8          "(__)-__"
        assertUnmasked(.init(-5, 2),  with: "(__)-__", is: .init(0, 1))
        assertUnmasked(.init(0, 2),   with: "(__)-__", is: .init(0, 1))
        assertUnmasked(.init(0, 8),   with: "(__)-__", is: .init(0, 4))
        assertUnmasked(.init(1, 4),   with: "(__)-__", is: .init(0, 2))
        assertUnmasked(.init(5, 5),   with: "(__)-__", is: .init(2, 2))
    }
    
    func test_unmaskRange_staticEdges() {
        
        //                          "12345"
        //                          "+1-2+"
        //                          "+N-N+"
        assertUnmasked(.init(1, 1), with: "+N-N+", is: .init(0, 1))
        assertUnmasked(.init(0, 4), with: "+N-N+", is: .init(0, 2))
    }
        
    func test_unmaskRange_singlePlaceholder() {
        
        assertUnmasked(.init(0, 1), with: "N", is: .init(0, 1))
        assertUnmasked(.init(0, 0), with: "N", is: .init(0, 0))
        assertUnmasked(.init(-5, 2), with: "N", is: .init(0, 1))
    }
    
    func test_unmaskRange_consecutivePlaceholders() {
        
        //                          "NNN-___-NN"
        assertUnmasked(.init(0, 3), with: "NNN-___-NN", is: .init(0, 3))
        assertUnmasked(.init(4, 3), with: "NNN-___-NN", is: .init(3, 3))
        assertUnmasked(.init(7, 1), with: "NNN-___-NN", is: .init(5, 1))
    }
    
    // MARK: - Helpers
    
    private func assertUnmasked(
        _ range: NSRange,
        with pattern: String,
        is expected: NSRange,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let mask = Mask(pattern: pattern)
        let unmasked = mask.unmask(range)
        
        XCTAssertNoDiff(
            unmasked,
            expected,
            "Expected \(expected) for \"\(pattern)\" and range \(range), but got \(unmasked) instead.",
            file: file,
            line: line
        )
    }
}

private extension NSRange {
    
    init(_ location: Int, _ length: Int) {
        
        self.init(location: location, length: length)
    }
}
