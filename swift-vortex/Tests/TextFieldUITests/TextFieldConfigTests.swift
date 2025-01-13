//
//  TextFieldConfigTests.swift
//  
//
//  Created by Igor Malyarov on 15.04.2023.
//

@testable import TextFieldUI
import XCTest

final class TextFieldConfigTests: XCTestCase {
    
    typealias Config = TextFieldView.TextFieldConfig
    
    func test_config() {
        
        let sut = Config(
            font: .systemFont(ofSize: 24),
            textColor: .pink,
            tintColor: .yellow,
            backgroundColor: .green,
            placeholderColor: .pink
        )
        
        XCTAssertNotNil(sut)
        XCTAssertNoDiff(sut.font.pointSize, 24)
        XCTAssertNoDiff(sut.textColor, .pink)
        XCTAssertNoDiff(sut.tintColor, .yellow)
        XCTAssertNoDiff(sut.backgroundColor, .green)
        XCTAssertNoDiff(sut.placeholderColor, .pink)
    }
}
