//
//  MaskValueTest.swift
//  ForaBankTests
//
//  Created by Дмитрий on 17.02.2022.
//

import XCTest
@testable import ForaBank

class MaskValueTest: XCTestCase {
 
    func testFilter() throws {

        // given
        let value = TextFieldComponent.filter(value: "121221 dsjomcmsd", regEx: "[0-9]")
        
        // when
        let result = "121221"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testCrop() throws {
        
        //given
        let value = TextFieldComponent.crop(value: "1234", max: 3)
        
        //when
        let result = "123"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testCropLessValues() throws {
        
        //given
        let value = TextFieldComponent.crop(value: "123", max: 10)
        
        //when
        let result = "123"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testMaskString() throws {
        
        //given
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let value = TextFieldComponent.maskValue(value: "1234123412341234", mask: cardMask)
        
        //when
        let result = "1234 1234 1234 1234"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testUpdatedMasked() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let updatedString = TextFieldComponent.updateMasked(value: "", inRange: NSRange(location: 0, length: 0), update: "6", masks: [cardMask], regExp: "[0-9]")
     
        let result = "6"
        
        XCTAssertEqual(updatedString, result)

    }
    
    func testAddSymbol() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let updatedString = TextFieldComponent.updateMasked(value: "6", inRange: NSRange(location: 1, length: 0), update: "7", masks: [cardMask], regExp: "[0-9]")
     
        let result = "67"
        
        XCTAssertEqual(updatedString, result)

    }
    
    func testAddRangeSymbol() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let updatedString = TextFieldComponent.updateMasked(value: "123456", inRange: NSRange(location: 2, length: 0), update: "6", masks: [cardMask], regExp: "[0-9]")
     
        let result = "1263456"
        
        XCTAssertEqual(updatedString, result)

    }
    
}
