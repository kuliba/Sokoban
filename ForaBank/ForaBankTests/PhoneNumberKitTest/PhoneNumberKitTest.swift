//
//  PhoneNumberKitTest.swift
//  ForaBankTests
//
//  Created by Константин Савялов on 28.12.2021.
//

import XCTest
import PhoneNumberKit
@testable import ForaBank

class PhoneNumberKitTest: XCTestCase {

    func testStringPhoneNumberKit() throws {

        // given
        let number = "+37410207469"
        let formater = PhoneNumberFormater()
    
        // when
        let result = formater.format(number)

        // then
        XCTAssertEqual(result, "+374 10 207469")
    }
    
    func testStringPhoneNumberKitRus() throws {

        // given
        let number = "+79255555555"
        let formater = PhoneNumberFormater()
    
        // when
        let result = formater.format(number)

        // then
        XCTAssertEqual(result, "+7 925 555-55-55")
    }
    
    func testTextFieldPhoneNumberKit() throws {

        // given
        let number = "+37410207469"
        let testField = PhoneNumberTextField()
        let formater = PhoneNumberFormater()
        // when
        testField.text = number
        let result = formater.format(testField)

        // then
        XCTAssertEqual(result, "+374 10 207469")
    }
    
}
