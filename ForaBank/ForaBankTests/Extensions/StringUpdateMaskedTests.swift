//
//  StringUpdateMaskedTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 15.04.2023.
//

@testable import ForaBank
import XCTest

final class StringUpdateMaskedTests: XCTestCase {
    
    // MARK: - updateMasked
    
    func test_updateMasked_shouldReturnUpdate_onNilValue() throws {
        
        let value: String? = nil
        let update = "ABC"
        
        let updatedMasked = makeSUT(value: value, update: update)
        
        XCTAssertEqual(updatedMasked, update)
    }
    
    func test_updateMasked_shouldInsertUpdate_onZeroLength() throws {
        
        let value = "abcdef"
        let update = "ABC"
        
        let updatedMasked = makeSUT(value: value, update: update)
        
        XCTAssertEqual(updatedMasked, "abABCcdef")
    }
    
    func test_updateMasked_shouldReplaceUpdate_onNonZeroLength() throws {
        
        let value = "abcdef"
        let update = "ABC"
        
        let updatedMasked = makeSUT(value: value, length: 2, update: update)
        
        XCTAssertEqual(updatedMasked, "abABCef")
    }
    func test_updateMasked_shouldReturnUpdate_onIncorrectLocation() throws {
        
        let value = "abcdef"
        let location = -2
        let update = "ABC"
        
        let updatedMasked = makeSUT(value: value, location: location, update: update)
        
        XCTAssertEqual(updatedMasked, "ABC")
    }
    
    func test_updateMasked_shouldReturnUpdate_onIncorrectLength() throws {
        
        let value = "abcdef"
        let length = 20
        let update = "ABC"
        
        let updatedMasked = makeSUT(value: value, length: length, update: update)
        
        XCTAssertEqual(updatedMasked, "ABC")
    }
    
    func test_updateMasked_should________onLastSymbolDelete() throws {
        
        let value = "a"
        let (location, length) = (1, 1)
        let update = ""
        
        let updatedMasked = makeSUT(value: value, location: location, length: length, update: update)
        
        XCTAssertEqual(updatedMasked, "")
    }
    
    func test_updateMasked_should_________onLastSymbolDelete() throws {
        
        let value = "a"
        let (location, length) = (0, 1)
        let update = ""
        
        let updatedMasked = makeSUT(value: value, location: location, length: length, update: update)
        
        XCTAssertEqual(updatedMasked, "")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        value: String?,
        location: Int = 2,
        length: Int = 0,
        update: String,
        limit: Int? = nil,
        style: StringFilteringStyle = .default
    ) -> String {
        
        let range: NSRange = .init(location: location, length: length)
        
        return value.updateMasked(inRange: range, update: update, limit: limit, style: style)
    }
}
