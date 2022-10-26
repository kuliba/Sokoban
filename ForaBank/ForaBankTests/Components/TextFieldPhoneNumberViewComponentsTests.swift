//
//  TextFieldPhoneNumberViewComponentsTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 26.10.2022.
//

import XCTest
@testable import ForaBank

class TextFieldPhoneNumberViewComponentsTests: XCTestCase {
    
    let phonePhormatter = PhoneNumberFormater()
    let phoneNumberFirstDigitReplaceList: [TextFieldPhoneNumberView.PhoneNumberFirstDigitReplace] = [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9")]
    
    func testUpdateFormatted_EnterFirstDigit() throws {
        
        //given
        let value: String? = ""
        let update = "7"
        let range = NSRange(location: 0, length: 0)

        // when
        let updatedString = TextFieldPhoneNumberView.updateMasked(value: value, inRange: range, update: update, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: phonePhormatter)
        
        // then
        XCTAssertEqual(updatedString, "+7")
    }
    
    func testUpdateFormatted_EnterFirstLetter() throws {
        
        //given
        let value: String? = ""
        let update = "п"
        let range = NSRange(location: 0, length: 0)

        // when
        let updatedString = TextFieldPhoneNumberView.updateMasked(value: value, inRange: range, update: update, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: phonePhormatter)
        
        // then
        XCTAssertEqual(updatedString, "п")
    }
    
    func testUpdateFormatted_RemoveSymbol() throws {
        
        //given
        let value: String? = "+7"
        let update = ""
        let range = NSRange(location: 1, length: 1)

        // when
        let updatedString = TextFieldPhoneNumberView.updateMasked(value: value, inRange: range, update: update, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: phonePhormatter)
        
        // then
        XCTAssertEqual(updatedString, "+")
    }
    
    func testUpdateFormatted_ReplaceDigit() throws {
        
        //given
        let value: String? = ""
        let update = "8"
        let range = NSRange(location: 0, length: 0)

        // when
        let updatedString = TextFieldPhoneNumberView.updateMasked(value: value, inRange: range, update: update, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: phonePhormatter)
        
        // then
        XCTAssertEqual(updatedString, "+7")
    }
    
    func testUpdateFormatted_PastePhoneNumber() throws {
        
        //given
        let value: String? = ""
        let update = "8 (925) 279 86 13"
        let range = NSRange(location: 0, length: 0)

        // when
        let updatedString = TextFieldPhoneNumberView.updateMasked(value: value, inRange: range, update: update, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: phonePhormatter)
        
        // then
        XCTAssertEqual(updatedString, "+7 925 279-86-13")
    }
}
