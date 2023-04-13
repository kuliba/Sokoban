//
//  StringReplacingTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.04.2023.
//

@testable import ForaBank
import XCTest

final class StringReplacingTests: XCTestCase {
    
    func test_replacing_shouldReturnReplacementText_onNegativeLocation() {
        
        let string = "abcdef"
        let (location, length) = (-2, 0)
        let updated = makeSUT(string: string, location: location, length: length)
        
        XCTAssertEqual(updated, "ABC")
        XCTAssertLessThan(location, 0)
    }
    
    func test_replacing_shouldReturnReplacementText_onLargeLocation() {
        
        let string = "abcdef"
        let (location, length) = (20, 0)
        let updated = makeSUT(string: string, location: location, length: length)
        
        XCTAssertEqual(updated, "ABC")
        XCTAssertGreaterThan(location, string.count)
    }
    
    func test_replacing_shouldReplace_onLocationZero_zeroLength() {
        
        let string = "abcdef"
        let (location, length) = (0, 0)
        let updated = makeSUT(string: string, location: location, length: length)
        
        XCTAssertEqual(updated, "ABCabcdef")
        XCTAssertEqual(0, location + length)
    }
    
    func test_replacing_shouldReplace_onLocationZero_nonZeroLength() {
        
        let string = "abcdef"
        let (location, length) = (0, 1)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "ABCbcdef")
        XCTAssertGreaterThan(string.count, location + length)
    }
    
    func test_replacing_shouldInsert_onZeroLength() {
        
        let string = "abcdef"
        let (location, length) = (1, 0)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "aABCbcdef")
    }
    
    func test_replacing_shouldInsertAndReplace_onNonZeroLength() {
        
        let string = "abcdef"
        let (location, length) = (1, 4)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "aABCf")
    }
    
    func test_replacing_shouldInsertAndReplace_onEqual() {
        
        let string = "abcdef"
        let (location, length) = (1, 5)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "aABC")
        XCTAssertEqual(string.count, location + length)
    }
    
    func test_replacing_shouldInsertAndReplace__onEqual() {
        
        let string = "abcdef"
        let (location, length) = (2, 4)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "abABC")
        XCTAssertEqual(string.count, location + length)
    }
    
    func test_replacing_shouldReplace_onSmaller() {
        
        let string = "abcdef"
        let (location, length) = (1, 6)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    func test_replacing_shouldReplace__onSmaller() {
        
        let string = "abcdef"
        let (location, length) = (2, 5)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    func test_replacing_shouldReplace_onLessThanLength() {
        
        let string = "abcdef"
        let (location, length) = (1, 7)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    func test_replacing_2() {
        
        let string = "abcdef"
        let (location, length) = (5, 0)
        let updated = makeSUT(string: string, location: location, length: length)
        
        XCTAssertEqual(updated, "abcdeABCf")
        XCTAssertGreaterThan(string.count, location + length)
    }
    
    func test_replacing_2a() {
        
        let string = "abcdef"
        let (location, length) = (6, 0)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "abcdefABC")
    }
    
    func test_replacing_shouldReturnReplacementText_onIncorrectLocation() {
        
        let string = "abcdef"
        let (location, length) = (20, 0)
        let updated = makeSUT(string: string, location: location, length: length)

        XCTAssertEqual(updated, "ABC")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        string: String,
        location: Int,
        length: Int,
        update: String = "ABC"
    ) -> String {
        
        let range = NSRange(location: location, length: length)
        
        return string.replacing(inRange: range, with: update)
    }
}
