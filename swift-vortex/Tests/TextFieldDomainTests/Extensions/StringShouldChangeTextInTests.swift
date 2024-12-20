//
//  StringShouldChangeTextInTests.swift
//  
//
//  Created by Igor Malyarov on 11.04.2023.
//

@testable import TextFieldDomain
import XCTest

final class StringShouldChangeTextInTests: XCTestCase {
    
    // MARK: - shouldChangeTextIn: Empty String
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onZeroLocationAndLength() {
        
        let string = ""
        let (location, length, text) = (0, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onZeroLocationLength1() {
        
        let string = ""
        let (location, length, text) = (0, 2, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onZeroLocationLength2() {
        
        let string = ""
        let (location, length, text) = (0, 2, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onLocation1ZeroLength() {
        
        let string = ""
        let (location, length, text) = (1, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onLocation2ZeroLength() {
        
        let string = ""
        let (location, length, text) = (2, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onNegativeLength() {
        
        let string = ""
        let (location, length, text) = (0, -1, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onNegativeLocation() {
        
        let string = ""
        let (location, length, text) = (-1, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_onBigNegativeLocation() {
        
        let string = ""
        let (location, length, text) = (-10, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    func test_shouldChangeTextIn_shouldReplaceEmptyString_on2NegativeLocation() {
        
        let string = ""
        let (location, length, text) = (-2, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, text)
    }
    
    // MARK: - shouldChangeTextIn: Appending String
    
    func test_shouldChangeTextIn_shouldAppendCharacters_atEnd0() {
        
        let string = ""
        let (location, length, text) = (0, 0, "a")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "a")
        XCTAssertNoDiff(string.count, location)
    }
    
    func test_shouldChangeTextIn_shouldAppendCharacters_atEnd1() {
        
        let string = "a"
        let (location, length, text) = (1, 0, "b")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ab")
        XCTAssertNoDiff(string.count, location)
    }
    
    func test_shouldChangeTextIn_shouldAppendCharacters_atEnd2() {
        
        let string = "ab"
        let (location, length, text) = (2, 0, "c")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "abc")
        XCTAssertNoDiff(string.count, location)
    }
    
    // MARK: - shouldChangeTextIn: Delete
    
    func test_shouldChangeTextIn_shouldDeleteCharacters_atEnd2() {
        
        let string = "abc"
        let (location, length, text) = (2, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ab")
        XCTAssertNoDiff(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldDeleteCharacters_atEnd1() {
        
        let string = "ab"
        let (location, length, text) = (1, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "a")
        XCTAssertNoDiff(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldDeleteCharacters_atEnd0() {
        
        let string = "a"
        let (location, length, text) = (0, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "")
        XCTAssertNoDiff(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldRemoveSymbolBeforeCursorL1L1() {
        
        let string = "abc"
        let (location, length, text) = (1, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ac")
    }
    
    func test_shouldChangeTextIn_shouldRemoveSymbolBeforeCursor() {
        
        let string = "ab"
        let (location, length, text) = (1, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "a")
    }
    
    func test_shouldChangeTextIn_shouldRemoveSymbolBeforeCursor0() {
        
        let string = "ab"
        let (location, length, text) = (0, 1, "")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "b")
    }
    
    // MARK: - shouldChangeTextIn: Insert (Length 0)
    
    func test_shouldChangeTextIn_shouldInsert_onLocationZero_onZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (0, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ABCabcdef")
        XCTAssertNoDiff(changed, text + string)
        XCTAssertNoDiff(0, location + length)
    }
    
    func test_shouldChangeTextIn_shouldInsert_onZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "aABCbcdef")
    }
    
    func test_shouldChangeTextIn_shouldInsert_onStringCountGreaterThanLocation_onZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (5, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "abcdeABCf")
        XCTAssertGreaterThan(string.count, location)
    }
    
    func test_shouldChangeTextIn_shouldAppendToEnd_onStringCountEqualToLocation_onLengthZero() {
        
        let string = "abcdef"
        let (location, length, text) = (6, 0, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "abcdefABC")
        XCTAssertNoDiff(string.count, location)
    }
    
    // MARK: - shouldChangeTextIn: NonEmpty String
    
    func test_shouldChangeTextIn_shouldReplace_onLocationZero_nonZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (0, 1, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ABCbcdef")
        XCTAssertGreaterThan(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace_onNonZeroLength() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 4, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "aABCf")
    }
    
    func test_shouldChangeTextIn_shouldInsertAndReplace_onEqual() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 5, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "aABC")
        XCTAssertNoDiff(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldInsertAndReplace__onEqual() {
        
        let string = "abcdef"
        let (location, length, text) = (2, 4, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "abABC")
        XCTAssertNoDiff(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace_onSmaller() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 6, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace__onSmaller() {
        
        let string = "abcdef"
        let (location, length, text) = (2, 5, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    func test_shouldChangeTextIn_shouldReplace_onLessThanLength() {
        
        let string = "abcdef"
        let (location, length, text) = (1, 7, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ABC")
        XCTAssertLessThan(string.count, location + length)
    }
    
    // MARK: - shouldChangeTextIn: NonEmpty Selection
    
    // MARK: - shouldChangeTextIn: Edge cases
    
    func test_shouldChangeTextIn_shouldReturnReplacementText_onIncorrectLocation() {
        
        let string = "abcdef"
        let (location, length, text) = (20, 1, "ABC")
        
        let changed = makeSUT(string: string, location: location, length: length, text: text)
        
        XCTAssertNoDiff(changed, "ABC")
    }
    
    func test_shouldChangeTextIn_shouldInsertAtLocation_onZeroLengthRange() {
        
        let text = "Abcde"
        let range = NSRange(location: 1, length: 0)
        let replacementText = "*"
        
        let result = text.shouldChangeTextIn(range: range, with: replacementText)
        
        XCTAssertNoDiff(result, "A*bcde")
    }
    
    func test_shouldChangeTextIn_shouldReplaceAfterLocation_onNonZeroLengthRange() {
        
        let text = "Abcde"
        let range = NSRange(location: 2, length: 2)
        let replacementText = "*"
        
        let result = text.shouldChangeTextIn(range: range, with: replacementText)
        
        XCTAssertNoDiff(result, "Ab*e")
    }
    
    func test_shouldChangeTextIn__shouldReturnReplacementText_onInvalidRange_negativeLocation() {
        
        let text = "Abcde"
        let range = NSRange(location: -1, length: 2)
        let replacementText = "*"
        
        let result = text.shouldChangeTextIn(range: range, with: replacementText)
        
        XCTAssertNoDiff(result, replacementText)
        XCTAssertLessThan(range.location, 0)
    }
    
    func test_shouldChangeTextIn__shouldReturnReplacementText_onInvalidRange_tooBigLocation() {
        
        let text = "Abcde"
        let range = NSRange(location: 6, length: 2)
        let replacementText = "*"
        
        let result = text.shouldChangeTextIn(range: range, with: replacementText)
        
        XCTAssertNoDiff(result, replacementText)
        XCTAssertGreaterThan(range.location, text.count)
    }
    
    func test_shouldChangeTextIn__shouldReturnReplacementText_onInvalidRange_negativeLength() {
        
        let text = "Abcde"
        let range = NSRange(location: 0, length: -1)
        let replacementText = "*"
        
        let result = text.shouldChangeTextIn(range: range, with: replacementText)
        
        XCTAssertNoDiff(result, replacementText)
        XCTAssertLessThan(range.length, 0)
    }
    
    func test_shouldChangeTextIn__shouldReturnReplacementText_onInvalidRange_tooBigLength() {
        
        let text = "Abcde"
        let range = NSRange(location: 0, length: 6)
        let replacementText = "*"
        
        let result = text.shouldChangeTextIn(range: range, with: replacementText)
        
        XCTAssertNoDiff(result, replacementText)
        XCTAssertGreaterThan(range.length + range.location, text.count)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        string: String,
        location: Int,
        length: Int,
        text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> String {
        
        let range = NSRange(location: location, length: length)
        
        return string.shouldChangeTextIn(range: range, with: text)
        
    }
}
