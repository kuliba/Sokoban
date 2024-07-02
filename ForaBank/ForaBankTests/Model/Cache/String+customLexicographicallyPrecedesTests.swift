//
//  String+customLexicographicallyPrecedesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.07.2024.
//

@testable import ForaBank
import XCTest

final class String_customLexicographicallyPrecedesTests: XCTestCase {

    func test_precedes_equalStrings() {
        
        XCTAssertFalse(precedes("apple", "apple"))
        XCTAssertFalse(precedes("123", "123"))
        XCTAssertFalse(precedes("эра", "эра"))
        XCTAssertFalse(precedes("-/<", "-/<"))
    }
    
    func test_precedes_shouldSortByCyrillicFirst() {
        
        XCTAssertTrue(precedes("терра", "эра"))
        XCTAssertTrue(precedes("эра", "apple"))
        XCTAssertTrue(precedes("эра", "1эра"))
        XCTAssertTrue(precedes("эра", "-эра"))
    }
        
    func test_precedes_shouldSortByLatin() {
        
        XCTAssertTrue(precedes("эра", "apple"))
        XCTAssertTrue(precedes("apple", "banana"))
        XCTAssertTrue(precedes("apple", "123"))
        XCTAssertTrue(precedes("apple", "-apple"))
    }
        
    func test_precedes_shouldSortByNumbers() {
        
        XCTAssertTrue(precedes("эра", "123"))
        XCTAssertTrue(precedes("apple", "123"))
        XCTAssertTrue(precedes("012", "123"))
        XCTAssertTrue(precedes("012", "-09"))
    }
    
    // MARK: - Helpers
    
    private func precedes(
        _ first: String,
        _ second: String
    ) -> Bool {
        
        return first.customLexicographicallyPrecedes(second)
    }
}
