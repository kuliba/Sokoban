//
//  StringExtensionsTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 07.12.2021.
//

import XCTest
@testable import ForaBank

class StringExtensionsTests: XCTestCase {

    func testContained_True() throws {

        // given
        let value = "test"
        let list = ["test", "data"]
        
        // when
        let result = value.contained(in: list)
        
        //then
        XCTAssertTrue(result)
    }
    
    func testContained_False() throws {

        // given
        let value = "test"
        let list = ["data", "other"]
        
        // when
        let result = value.contained(in: list)
        
        //then
        XCTAssertFalse(result)
    }
    
    func testFilter() throws {

        // given
        let value = try "121221 dsjomcmsd".filterred(regEx: "[0-9]")
        
        // when
        let result = "121221"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testCrop() throws {
        
        //given
        let value = "1234".cropped(max: 3)
        
        //when
        let result = "123"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testCrop_LessValues() throws {
        
        //given
        let value = "123".cropped(max: 10)

        //when
        let result = "123"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testMasked() throws {
        
        //given
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let value = "1234123412341234".masked(mask: cardMask)

        //when
        let result = "1234 1234 1234 1234"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testIsComplete_False() {
        
        // given
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let value = "1234 12"
        
        // when
        let result = value.isComplete(for: cardMask)
        
        // then
        XCTAssertFalse(result)
    }
    
    func testIsComplete_True() {
        
        // given
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let value = "1234 1234 6789 8990"
        
        // when
        let result = value.isComplete(for: cardMask)
        
        // then
        XCTAssertTrue(result)
    }
}
