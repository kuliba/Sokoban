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
        let value = try "121221 dsjomcmsd".filtered(regEx: "[0-9]")
        
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
    
    func test_formatted_defaultValue_Equal() {
        
        // given
        let cardNumberValue = "1234123467898990"
        
        // when
        let result = cardNumberValue.formatted()
        
        // then
        XCTAssertEqual(result, "1234 1234 6789 8990")
    }
    
    func test_formatted_defaultValue_NotEqual() {
        
        // given
        let cardNumberValue = "1234123467898990"
        
        // when
        let result = cardNumberValue.formatted()
        
        // then
        XCTAssertNotEqual(result, "1234 1234 67898990")
    }
    
    func test_formatted_customValue_Equal() {
        
        // given
        let cardNumberValue = "1234123467898990"
        
        // when
        let result = cardNumberValue.formatted(
            withChunkSize: 3,
            withSeparator: "*"
        )
        
        // then
        XCTAssertEqual(result, "123*412*346*789*899*0")
    }
    
    func test_formatted_customValue_NotEqual() {
        
        // given
        let cardNumberValue = "1234123467898990"
        
        // when
        let result = cardNumberValue.formatted(
            withChunkSize: 3,
            withSeparator: "/"
        )
        
        // then
        XCTAssertNotEqual(result, "1234 1234 67898990")
    }
    
    func test_cardNumberMasked_emptyNumber() {
        
        XCTAssertNoDiff("".cardNumberMasked(), "")
    }

    func test_cardNumberMasked_fullNumber() {
        
        XCTAssertNoDiff("1234123467898990".cardNumberMasked(), "1234 12** **** 8990")
    }
    
    func test_cardNumberMasked_numberLessThen4digits() {
        
        XCTAssertNoDiff("123".cardNumberMasked(), "123")
    }

    func test_cardNumberMasked_numberLessThen12digits() {
        
        XCTAssertNoDiff("12341234678".cardNumberMasked(), "1234 12** ***")
    }

    func test_cardNumberMasked_numberMoreThen16digits() {
        
        XCTAssertNoDiff("12341234678989901234".cardNumberMasked(), "1234 12** **** 8990 1234")
    }
}
