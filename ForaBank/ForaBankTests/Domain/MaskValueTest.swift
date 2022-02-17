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
        let value = TextFieldComponent.filter(value: "121221 dsjomcmsd")
        
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
    
    func testUnmask() throws {
        
        //given
        let value = TextFieldComponent.unmask(value: "4444 4444 4444 4444", regEx: "[0-9]")
        
        //when
        let result = "4444444444444444"
        
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
    
    
}
