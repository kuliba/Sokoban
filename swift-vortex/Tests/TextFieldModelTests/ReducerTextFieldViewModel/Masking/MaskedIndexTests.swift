//
//  MaskedIndexTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 11.01.2025.
//

import XCTest

final class MaskedIndexTests: XCTestCase {
    
    func test_phone() {
        
        //            "01234567890123456"
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
        
        //            "01234"
        //            "01.23"
        let pattern = "__.__"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 0)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 2)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 3)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 4)
        
        XCTAssertNil(pattern.maskedIndex(for: 4))
    }
    
    func test_longDate() {
        
        //            "0123456"
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
        XCTAssertEqual(pattern.maskedIndex(for: 6), 6)
        
        XCTAssertNil(pattern.maskedIndex(for: 7))
    }
    
    func test_staticOnly_shouldIncludeAllStaticChars() {
        
        let pattern = "+7 ( ) -"
        
        XCTAssertNil(pattern.maskedIndex(for: 0))
    }
    
    func test_staticAndPlaceholderMix() {
        
        //            "123456"
        //            "AB012C"
        let pattern = "AB_N_C"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 2)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 3)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 5)
        
        XCTAssertNil(pattern.maskedIndex(for: 3))
    }
    
    func test_edgeCases() {
        
        //            "0123456"
        //            "(01)-23"
        let pattern = "(__)-__"
        
        XCTAssertEqual(pattern.maskedIndex(for: 0), 1)
        XCTAssertEqual(pattern.maskedIndex(for: 1), 4)
        XCTAssertEqual(pattern.maskedIndex(for: 2), 5)
        XCTAssertEqual(pattern.maskedIndex(for: 3), 6)
        
        XCTAssertNil(pattern.maskedIndex(for: 4))
    }
    
    func test_alternatingStaticAndPlaceholder() {
        
        //            "01234567890"
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
