//
//  PhoneValidatorTests.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

@testable import Vortex
import XCTest

final class PhoneValidatorTests: XCTestCase {

    func testPhoneValidator() {
        
        let phoneValidator = PhoneValidator()
        
        XCTAssertFalse(phoneValidator.isValid("1"))
        XCTAssertFalse(phoneValidator.isValid("3"))
        XCTAssertFalse(phoneValidator.isValid("+374"))
        XCTAssertFalse(phoneValidator.isValid(" 79161111111"))
        
        XCTAssert(phoneValidator.isValid("79161111111"))
        XCTAssert(phoneValidator.isValid("7 9161111111"))
        XCTAssert(phoneValidator.isValid("7 916 1111111"))
        XCTAssert(phoneValidator.isValid("7 916 111 1111"))
        XCTAssert(phoneValidator.isValid("7 916 111 11 11"))
        XCTAssert(phoneValidator.isValid("7 (916) 111 11 11"))
        XCTAssert(phoneValidator.isValid("+79161111111"))
        XCTAssert(phoneValidator.isValid("+7 916 111-11-11"))
    }
}
