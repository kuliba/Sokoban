//
//  SortKeyTests.swift
//
//
//  Created by Igor Malyarov on 08.12.2024.
//

import VortexTools
import XCTest

final class SortKeyTests: XCTestCase {
    
    func test_shouldInitializeSortKey() {
        
        let string = "aB3!"
        let sortKey = sortKey(for: string)
        
        XCTAssertEqual(sortKey.priorityArray, [2, 2, 3, 4], "Priority array should match expected values.")
        XCTAssertEqual(sortKey.characters, Array(string), "Characters array should match the string's characters.")
    }
    
    func test_shouldRecognizeEqualSortKeys() {
        
        let string1 = "abc123"
        let string2 = "abc123"
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertEqual(sortKey1, sortKey2, "SortKeys with identical strings and priorities should be equal.")
    }
    
    func test_shouldDetectInequalityWithDifferentPriority() {
        
        let string1 = "abc123"
        let string2 = "abc124"
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with different characters should not be equal.")
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 based on character '3' < '4'.")
    }
    
    func test_shouldDetectInequalityWithDifferentLength() {
        
        let string1 = "abc"
        let string2 = "abcd"
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with different lengths should not be equal.")
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 because it's shorter.")
    }
    
    func test_shouldCompareSortKeysWithDifferentPriorities() {
        
        let string1 = "abc"
        let string2 = "abc1"
        let sortKey1 = sortKey(for: string1) // [1,1,1]
        let sortKey2 = sortKey(for: string2) // [1,1,1,2]
        
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 because it has fewer elements.")
    }
    
    func test_shouldCompareSortKeysWithMixedPriorities() {
        
        let string1 = "a1b2"
        let string2 = "a1b3"
        let sortKey1 = sortKey(for: string1) // [2,3,2,3]
        let sortKey2 = sortKey(for: string2) // [2,3,2,3]
        
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 because '2' < '3' in the last character.")
    }
    
    func test_shouldHandleSpecialCharactersComparison() {
        
        let string1 = "abc!"
        let string2 = "abc@"
        let sortKey1 = sortKey(for: string1) // [2,2,2,4]
        let sortKey2 = sortKey(for: string2) // [2,2,2,4]
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with different special characters should not be equal.")
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 because '!' < '@'.")
    }
    
    func test_shouldRespectCaseSensitivityInComparison() {
        
        let string1 = "abc"
        let string2 = "Abc"
        let sortKey1 = sortKey(for: string1) // [2,2,2]
        let sortKey2 = sortKey(for: string2) // [2,2,2]
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with different cases should not be equal.")
        XCTAssertGreaterThan(sortKey1, sortKey2, "SortKey1 should be greater than SortKey2 because 'a' > 'A'.")
    }
    
    func test_shouldInitializeSortKeyWithEmptyString() {
        
        let string = ""
        let sortKey = sortKey(for: string)
        
        XCTAssertEqual(sortKey.priorityArray, [], "Priority array should be empty for an empty string.")
        XCTAssertEqual(sortKey.characters, [], "Characters array should be empty for an empty string.")
    }
    
    func test_shouldRecognizeEqualityWithEmptyStrings() {
        
        let string1 = ""
        let string2 = ""
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertEqual(sortKey1, sortKey2, "SortKeys of two empty strings should be equal.")
    }
    
    func test_shouldCompareSortKeysWithMixedUnicodeAndASCII() {
        
        let string1 = "aБc"
        let string2 = "aBc"
        let sortKey1 = sortKey(for: string1) // [2,1,2]
        let sortKey2 = sortKey(for: string2) // [2,2,2]
        
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 based on Unicode character ordering.")
    }
    
    func test_shouldHandleUnicodeCharactersEquality() {
        
        let string1 = "こんにちは" // Japanese Hiragana
        let string2 = "こんにちは"
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertEqual(sortKey1, sortKey2, "SortKeys with identical Unicode strings should be equal.")
    }
    
    func test_shouldCompareSortKeysWithOnlySpecialCharacters() {
        
        let string1 = "!@#$"
        let string2 = "!@%$"
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with different special characters should not be equal.")
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 based on special character ordering.")
    }
    
    func test_shouldCompareSortKeysWithLongStrings() {
        
        let string1 = String(repeating: "aA1!", count: 1000)
        let string2 = String(repeating: "aA1@", count: 1000)
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with different long strings should not be equal.")
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 based on the last character.")
    }
    
    func test_shouldCompareSortKeysWithPriorityDifferenceInMiddle() {
        
        let string1 = "a1b2c3"
        let string2 = "a1b3c2"
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 based on priority difference in the middle.")
    }
    
    func test_shouldHandleDifferentPriorityAssignments() {
        
        let customPriority: (Character) -> Int = { char in
            return char.isUppercase ? 1 : 2
        }
        
        let string1 = "AbC"
        let string2 = "aBc"
        let sortKey1 = string1.sortKey(priority: customPriority)
        let sortKey2 = string2.sortKey(priority: customPriority)
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with different case-based priorities should not be equal.")
        XCTAssertLessThan(sortKey1, sortKey2, "SortKey1 should be less than SortKey2 based on custom priority assignments.")
    }
    
    func test_shouldHandleMaximumCharacterValues() throws {
        
        let scalar1 = try XCTUnwrap(UnicodeScalar(0x10FFFF), "Failed to create Unicode scalar 0x10FFFF")
        let scalar2 = try XCTUnwrap(UnicodeScalar(0x10FFFE), "Failed to create Unicode scalar 0x10FFFE")
        
        let string1 = String(scalar1)
        let string2 = String(scalar2)
        let sortKey1 = sortKey(for: string1)
        let sortKey2 = sortKey(for: string2)
        
        XCTAssertNotEqual(sortKey1, sortKey2, "SortKeys with maximum Unicode characters should not be equal.")
        XCTAssertGreaterThan(sortKey1, sortKey2, "SortKey1 should be greater than SortKey2 based on maximum Unicode character.")
    }
    
    func test_shouldMaintainSortKeyConsistency() {
        
        let string = "ConsistencyTest123!"
        let sortKey1 = sortKey(for: string)
        let sortKey2 = sortKey(for: string)
        
        XCTAssertEqual(sortKey1, sortKey2, "SortKeys from multiple invocations with the same string should be equal.")
    }
    
    func test_shouldHandleInvalidCharacters() {
        
        // Use a valid Unicode character that falls outside the ASCII range
        let string = "\u{FFFD}" // Unicode Replacement Character
        let sortKey = sortKey(for: string)
        
        XCTAssertEqual(sortKey.priorityArray, [4], "Invalid characters should receive the default priority.")
        XCTAssertEqual(sortKey.characters, [Character("\u{FFFD}")], "Characters array should contain the replacement character.")
    }
    
    // MARK: - Helpers
    
    private func sortKey(for string: String) -> SortKey {
        
        return string.sortKey(priority: samplePriority)
    }
    
    private func samplePriority(_ char: Character) -> Int {
        
        switch char {
        case "\u{0400}"..."\u{04FF}":
            return 1  // Priority 1 for Cyrillic characters
        case "A"..."Z", "a"..."z":
            return 2  // Priority 2 for Latin characters
        case "0"..."9":
            return 3  // Priority 3 for numbers
        default:
            return 4  // Priority 4 for other characters
        }
    }
}
