//
//  TextState+DSL.swift
//  VortexTests
//
//  Created by Igor Malyarov on 22.05.2023.
//

import TextFieldComponent
import XCTest

extension XCTestCase {
    
    func assertTextState(
        _ state: TextState,
        hasText text: String,
        cursorAt cursor: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        XCTAssertNoDiff(state.text, text, file: file, line: line)
        XCTAssertNoDiff(state.cursorPosition, cursor, file: file, line: line)
    }
}
