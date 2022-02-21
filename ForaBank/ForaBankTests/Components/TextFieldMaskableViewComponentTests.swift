//
//  TextFieldMaskableViewComponentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.02.2022.
//

import XCTest
@testable import ForaBank

class TextFieldMaskableViewComponentTests: XCTestCase {
    
    func testUpdateMasked_Nil_Value_Add_Single_Update() throws {
        
        //given
        let value: String? = nil
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let accountMask = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
        let update = "6"
        let range = NSRange(location: 0, length: 0)
        let regExp = "[0-9]"
        
        // when
        let updatedString = TextFieldMaskableView.updateMasked(value: value, inRange: range, update: update, masks: [cardMask, accountMask], regExp: regExp)
        
        // then
        XCTAssertEqual(updatedString, "6")
    }
    
    func testUpdateMasked_Empty_Value_Add_Single_Update() throws {
        
        //given
        let value = ""
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let accountMask = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
        let update = "6"
        let range = NSRange(location: 0, length: 0)
        let regExp = "[0-9]"
        
        // when
        let updatedString = TextFieldMaskableView.updateMasked(value: value, inRange: range, update: update, masks: [cardMask, accountMask], regExp: regExp)
        
        // then
        XCTAssertEqual(updatedString, "6")
    }
    
    func testUpdateMasked_Add_Single_Update() throws {
        
        //given
        let value = "6"
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let accountMask = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
        let update = "7"
        let range = NSRange(location: 1, length: 0)
        let regExp = "[0-9]"
        
        // when
        let updatedString = TextFieldMaskableView.updateMasked(value: value, inRange: range, update: update, masks: [cardMask, accountMask], regExp: regExp)
        
        // thwn
        XCTAssertEqual(updatedString, "67")
    }
    
    func testUpdateMasked_Insert_Single_Update() throws {
        
        //given
        let value = "1234 56"
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let accountMask = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
        let update = "6"
        let range = NSRange(location: 2, length: 0)
        let regExp = "[0-9]"
        
        // when
        let updatedString = TextFieldMaskableView.updateMasked(value: value, inRange: range, update: update, masks: [cardMask, accountMask], regExp: regExp)
        
        // then
        XCTAssertEqual(updatedString, "1263 456")
    }
    
    func testUpdateMasked_Insert_Multiple_Unfilterred_Update() throws {
        
        //given
        let value = "1234 5678 8901 2"
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let accountMask = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
        let update = "12j3 yf45lk6789 01kl"
        let range = NSRange(location: 2, length: 5)
        let regExp = "[0-9]"
        
        // when
        let updatedString = TextFieldMaskableView.updateMasked(value: value, inRange: range, update: update, masks: [cardMask, accountMask], regExp: regExp)
        
        // then
        XCTAssertEqual(updatedString, "12123 4 567 8901 7889012")
    }
    
    func testUpdateMasked_Masked_Value_Add_Single_Update() throws {
        
        //given
        let value = "1234 5"
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let accountMask = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
        let update = "1"
        let range = NSRange(location: 6, length: 0)
        let regExp = "[0-9]"
        
        // when
        let updatedString = TextFieldMaskableView.updateMasked(value: value, inRange: range, update: update, masks: [cardMask, accountMask], regExp: regExp)
        
        // then
        XCTAssertEqual(updatedString, "1234 51")
    }
    
    func testUpdateMasked_Single_Value_Remove_Single() throws {
        
        //given
        let value = "1"
        let cardMask = StringValueMask(mask: "#### #### #### ####", symbol: "#")
        let accountMask = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
        let update = ""
        let range = NSRange(location: 0, length: 1)
        let regExp = "[0-9]"
        
        // when
        let updatedString = TextFieldMaskableView.updateMasked(value: value, inRange: range, update: update, masks: [cardMask, accountMask], regExp: regExp)
        
        XCTAssertNil(updatedString)
    }
}
