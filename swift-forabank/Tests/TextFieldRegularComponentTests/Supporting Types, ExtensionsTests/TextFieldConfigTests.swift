//
//  TextFieldConfigTests.swift
//  
//
//  Created by Igor Malyarov on 15.04.2023.
//

@testable import TextFieldRegularComponent
import XCTest

final class TextFieldConfigTests: XCTestCase {
    
    typealias Config = TextFieldRegularView.TextFieldConfig
    
    func test_config() {
        
        let sut = Config(
            font: .systemFont(ofSize: 24),
            textColor: .pink,
            tintColor: .yellow,
            backgroundColor: .green
        )
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.font.pointSize, 24)
        XCTAssertEqual(sut.textColor, .pink)
        XCTAssertEqual(sut.tintColor, .yellow)
        XCTAssertEqual(sut.backgroundColor, .green)
    }
}
