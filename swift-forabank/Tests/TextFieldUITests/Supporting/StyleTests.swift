//
//  StyleTests.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

@testable import TextFieldDomain
import XCTest

final class StyleTests: XCTestCase {

    func test_uiKeyboardType() {
        
        XCTAssertEqual(KeyboardType.default.uiKeyboardType, .default)
        XCTAssertEqual(KeyboardType.number.uiKeyboardType, .numberPad)
    }
}
