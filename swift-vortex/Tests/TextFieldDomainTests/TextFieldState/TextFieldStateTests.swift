//
//  TextFieldStateTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

@testable import TextFieldDomain
import XCTest

final class TextFieldStateTests: XCTestCase {
    
    func test_init_withString_shouldSetToPlaceholder() {
        
        let text = "Any text"
        let state = TextFieldState(text)
        
        XCTAssertNoDiff(state, .placeholder(text))
    }
}
