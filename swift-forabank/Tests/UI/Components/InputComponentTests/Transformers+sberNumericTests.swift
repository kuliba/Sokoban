//
//  Transformers+sberNumericTests.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import InputComponent
import TextFieldModel
import XCTest

final class Transformers_sberNumericTests: XCTestCase {
    
    // MARK: - SBER Providers: numeric should have period as decimal separator
    
    func test_sberNumeric() {
        
        let transform = Transformers.sberNumeric.transform
        
        XCTAssertEqual(transform(.init("123,45")).text, "123.45")
        XCTAssertEqual(transform(.init("123,45,67")).text, "123.4567")
        XCTAssertEqual(transform(.init("123,45.67")).text, "123.4567")
        XCTAssertEqual(transform(.init("123.45.67")).text, "123.4567")
        
        XCTAssertEqual(transform(.init("ab123er,4-5")).text, "123.45")
    }
}
