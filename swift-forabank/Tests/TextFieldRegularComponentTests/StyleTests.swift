//
//  StyleTests.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

@testable import TextFieldRegularComponent
import XCTest

final class StyleTests: XCTestCase {

    func test_uiKeyboardType() {
        
        typealias KeyboardType = TextFieldRegularView.ViewModel.KeyboardType
        
        XCTAssertEqual(KeyboardType.default.uiKeyboardType, .default)
        XCTAssertEqual(KeyboardType.number.uiKeyboardType, .numberPad)
    }
}
