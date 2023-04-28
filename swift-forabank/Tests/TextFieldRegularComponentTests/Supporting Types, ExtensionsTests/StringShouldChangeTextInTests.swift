//
//  StringShouldChangeTextInTests.swift
//  
//
//  Created by Igor Malyarov on 11.04.2023.
//

@testable import TextFieldRegularComponent
import XCTest

final class StringShouldChangeTextInTests: XCTestCase {
    
    // MARK: - shouldChangeTextIn: Empty String
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onZeroLocationAndLength() {
        
        let string = ""
        let (location, length, text) = (0, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onZeroLocationLength1() {
        
        let string = ""
        let (location, length, text) = (0, 2, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onZeroLocationLength2() {
        
        let string = ""
        let (location, length, text) = (0, 2, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onLocation1ZeroLength() {
        
        let string = ""
        let (location, length, text) = (1, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onLocation2ZeroLength() {
        
        let string = ""
        let (location, length, text) = (2, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onNegativeLength() {
        
        let string = ""
        let (location, length, text) = (0, -1, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onNegativeLocation() {
        
        let string = ""
        let (location, length, text) = (-1, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onBigNegativeLocation() {
        
        let string = ""
        let (location, length, text) = (-10, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_on2NegativeLocation() {
        
        let string = ""
        let (location, length, text) = (-2, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, text)
    }
    
    // MARK: - shouldChangeTextIn: Appending String
    
    func test_shouldChangeTextIn_shouldAppendCharacters_atEnd0() {
        
        let string = ""
        let (location, length, text) = (0, 0, "a")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "a")
        XCTAssertEqual(string.count, location)
    }
    
    func test_shouldChangeTextIn_shouldAppendCharacters_atEnd1() {
        
        let string = "a"
        let (location, length, text) = (1, 0, "b")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ab")
        XCTAssertEqual(string.count, location)
    }
    
    func test_shouldChangeTextIn_shouldAppendCharacters_atEnd2() {
        
        let string = "ab"
        let (location, length, text) = (2, 0, "c")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "abc")
        XCTAssertEqual(string.count, location)
    }
    
    // MARK: - shouldChangeTextIn: Delete
    
    func test_shouldChangeTextIn_shouldDeleteCharacters_atEnd2() {
        
        let string = "abc"
        let (location, length, text) = (2, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ab")
        XCTAssertEqual(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldDeleteCharacters_atEnd1() {
        
        let string = "ab"
        let (location, length, text) = (1, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "a")
        XCTAssertEqual(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldDeleteCharacters_atEnd0() {
        
        let string = "a"
        let (location, length, text) = (0, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "")
        XCTAssertEqual(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldRemoveSymbolBeforeCursorL1L1() {
        
        let string = "abc"
        let (location, length, text) = (1, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ac")
    }
    
    func test_shouldChangeTextIn_shouldRemoveSymbolBeforeCursor() {
        
        let string = "ab"
        let (location, length, text) = (1, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "a")
    }
    
    func test_shouldChangeTextIn_shouldRemoveSymbolBeforeCursor0() {
        
        let string = "ab"
        let (location, length, text) = (0, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "b")
    }
    
    // MARK: - shouldChangeTextIn: Insert (Length 0)
    
    func test_shouldChangeTextIn_shouldInsert_onLocationZero_onZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (0, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ABCabcdef")
        XCTAssertEqual(changed, text + string)
        XCTAssertEqual(0, location + length)
    }
    
    func test_shouldChangeTextIn_shouldInsert_onZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "aABCbcdef")
    }
    
    func test_shouldChangeTextIn_shouldInsert_onStringCountGreaterThanLocation_onZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (5, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "abcdeABCf")
        XCTAssertGreaterThan(string.count, location)
    }
    
    func test_shouldChangeTextIn_shouldAppendToEnd_onStringCountEqualToLocation_onLengthZero() {
        
        let string = "abcdef"
        let (location, length, text) = (6, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "abcdefABC")
        XCTAssertEqual(string.count, location)
    }
    
    // MARK: - shouldChangeTextIn: NonEmpty String
    
    func test_shouldChangeTextIn_shouldReplace_onLocationZero_nonZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (0, 1, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ABCbcdef")
        XCTAssertGreaterThan(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace_onNonZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 4, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "aABCf")
    }
    
    func test_shouldChangeTextIn_shouldInsertAndReplace_onEqual() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 5, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "aABC")
        XCTAssertEqual(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldInsertAndReplace__onEqual() {
        
        let string = "abcdef"
        let (location, length, text) = (2, 4, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "abABC")
        XCTAssertEqual(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace_onSmaller() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 6, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace__onSmaller() {
        
        let string = "abcdef"
        let (location, length, text) = (2, 5, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace_onLessThanLength() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 7, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    // MARK: - shouldChangeTextIn: NonEmpty Selection

    // MARK: - shouldChangeTextIn: Edge cases
    
    func test_shouldChangeTextIn_shouldReturnReplacementText_onIncorrectLocation() {
        
        let string = "abcdef"
        let (location, length, text) = (20, 1, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertEqual(changed, "ABC")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        string: String,
        location: Int,
        length: Int,
        text: String
    ) -> String {
        
        let range = NSRange(location: location, length: length)
        
        return string.shouldChangeTextIn(range: range, with: text)
    }
}
