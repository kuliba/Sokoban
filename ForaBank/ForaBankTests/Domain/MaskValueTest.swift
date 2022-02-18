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
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let value = TextFieldComponent.maskValue(value: "1234123412341234", mask: cardMask)
        
        //when
        let result = "1234 1234 1234 1234"
        
        //then
        XCTAssertEqual(value, result)
    }
    
    func testUpdatedMasked() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let accountMask = TextFieldComponent.StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        let updatedString = TextFieldComponent.updateMasked(value: "", inRange: NSRange(location: 0, length: 0), update: "6", masks: [cardMask, accountMask], regExp: "[0-9]")
     
        let result = "6"
        
        XCTAssertEqual(updatedString, result)

    }
    
    func testAddSymbol() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let accountMask = TextFieldComponent.StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        let updatedString = TextFieldComponent.updateMasked(value: "6", inRange: NSRange(location: 1, length: 0), update: "7", masks: [cardMask, accountMask], regExp: "[0-9]")
     
        let result = "67"
        
        XCTAssertEqual(updatedString, result)

    }
    
    func testAddRangeSymbol() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let accountMask = TextFieldComponent.StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        let updatedString = TextFieldComponent.updateMasked(value: "123456", inRange: NSRange(location: 2, length: 0), update: "6", masks: [cardMask, accountMask], regExp: "[0-9]")
     
        let result = "1263 456"
        
        XCTAssertEqual(updatedString, result)

    }
    
    func testUpdate_AccountMask() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let accountMask = TextFieldComponent.StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        let updatedString = TextFieldComponent.updateMasked(value: "1234 5678 8901 2", inRange: NSRange(location: 2, length: 5), update: "12j3 yf45lk6789 01kl", masks: [cardMask, accountMask], regExp: "[0-9]")
        
        XCTAssertEqual(updatedString, "12123 4 567 8901 7889012")
    }
    
    func testUpdate_CardMask() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let accountMask = TextFieldComponent.StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        let updatedString = TextFieldComponent.updateMasked(value: "1234 5", inRange: NSRange(location: 6, length: 0), update: "1", masks: [cardMask, accountMask], regExp: "[0-9]")
        
        XCTAssertEqual(updatedString, "1234 51")
    }
    
    
    func testUpdated_Delete() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let accountMask = TextFieldComponent.StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        let updatedString = TextFieldComponent.updateMasked(value: "1", inRange: NSRange(location: 0, length: 1), update: "", masks: [cardMask, accountMask], regExp: "[0-9]")
        
        XCTAssertEqual(updatedString, "")
    }
    
    func testUpdated_AddSymbol() throws {
        
        let cardMask = TextFieldComponent.StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        let accountMask = TextFieldComponent.StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        let updatedString = TextFieldComponent.updateMasked(value: "1", inRange: NSRange(location: 1, length: 0), update: "2", masks: [cardMask, accountMask], regExp: "[0-9]")
        
        XCTAssertEqual(updatedString, "12")
    }
    
}
