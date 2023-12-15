//
//  NSRange+clampedTests.swift
//  
//
//  Created by Igor Malyarov on 15.12.2023.
//

import XCTest

final class NSRange_clampedTests: XCTestCase {
    
    func test_clamped() throws {
        
        let text = "hello"
        let nsRange = NSRange(location: 1, length: 6)
        XCTAssertNoDiff(nsRange.upperBound, 7)
        
        let clamped = nsRange.clamped(to: text, droppingLast: 1)
        
        XCTAssertNoDiff(clamped.location, 1)
        XCTAssertNoDiff(clamped.length, 3)
        
        let range = try XCTUnwrap(Range(clamped, in: text))
        XCTAssertNoDiff(text[range], "ell")
    }
}
