//
//  StringRestrictedTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.04.2023.
//

@testable import ForaBank
import XCTest

final class StringRestrictedTests: XCTestCase {
    
    func test_restricted_shouldReturnSame_onNilLimit_default() {

        let string = "abcdefgh"
        let limit = Int?.none
        let restricted = makeSUT(string, limit: limit, style: .default)
        
        XCTAssertEqual(string, restricted)
        XCTAssertNil(limit)
    }
    
    func test_restricted_shouldReturnSame_onLimitGreaterThanLength_default() {
        
        let string = "abcdefgh"
        let limit = 9
        let restricted = makeSUT(string, limit: limit, style: .default)
        
        XCTAssertEqual(string, restricted)
        XCTAssertGreaterThan(limit, string.count)
    }
    
    func test_restricted_shouldReturnSame_onLimitEqualToLength_default() {
        
        let string = "abcdefgh"
        let limit = 8
        let restricted = makeSUT(string, limit: limit, style: .default)
        
        XCTAssertEqual(string, restricted)
        XCTAssertEqual(limit, string.count)
    }
    
    func test_restricted_shouldReturnPrefixed_onLimitEqualToLength_default() {
        
        let string = "abcdefgh"
        let limit = 7
        let restricted = makeSUT(string, limit: limit, style: .default)
        
        XCTAssertEqual("abcdefg", restricted)
        XCTAssertLessThan(limit, string.count)
    }
    
    func test_restricted_shouldReturnSame_numbersOnly_onNilLimit_number() {
        
        let string = "12345678"
        let limit = Int?.none
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        XCTAssertEqual(string, restricted)
        XCTAssertNil(limit)
    }
    
    func test_restricted_shouldReturnSame_numbersOnly_onLimitGreaterThanLength_number() {
        
        let string = "12345678"
        let limit = 9
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        XCTAssertEqual(string, restricted)
        XCTAssertGreaterThan(limit, string.count)
    }
    
    func test_restricted_shouldReturnSame_numbersOnly_onLimitEqualToLength_number() {
        
        let string = "12345678"
        let limit = 8
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        XCTAssertEqual(string, restricted)
        XCTAssertEqual(limit, string.count)
    }
    
    func test_restricted_shouldReturnPrefixed_numbersOnly_onLimitEqualToLength_number() {
        
        let string = "12345678"
        let limit = 7
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        XCTAssertEqual("1234567", restricted)
        XCTAssertLessThan(limit, string.count)
    }
    
    func test_restricted_shouldReturn___mixed_onNilLimit_number() {
        
        let string = "1a2345678"
        let limit = Int?.none
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        XCTAssertEqual("12345678", restricted)
        XCTAssertNil(limit)
    }
    
    func test_restricted_shouldReturn___mixed_onLimitGreaterThanLength_number() {
        
        let string = "1a2345678"
        let limit = 9
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        let expected = "12345678"
        
        XCTAssertEqual(expected, restricted)
        XCTAssertGreaterThan(limit, expected.count)
    }
    
    func test_restricted_shouldReturn___mixed_onLimitEqualToLength_number() {
        
        let string = "1a2345678"
        let limit = 8
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        let expected = "12345678"
        
        XCTAssertEqual("12345678", restricted)
        XCTAssertEqual(limit, expected.count)
    }
    
    func test_restricted_shouldReturn____mixed_onLimitEqualToLength_number() {
        
        let string = "1a2345678"
        let limit = 7
        let restricted = makeSUT(string, limit: limit, style: .number)
        
        let numbers = "12345678"
        let expected = "1234567"
        
        XCTAssertEqual(expected, restricted)
        XCTAssertLessThan(limit, numbers.count)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        _ string: String,
        limit: Int? = nil,
        style: StringFilteringStyle
    ) -> String {
        
        return string.restricted(withLimit: limit, forStyle: style)
    }
}
