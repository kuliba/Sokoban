//
//  MaskTests.swift
//
//
//  Created by Igor Malyarov on 10.01.2025.
//

@testable import TextFieldDomain
import XCTest

class MaskTests: XCTestCase {
    
    // MARK: - Helpers
    
    func makeState(
        _ text: String,
        cursorAt cursorPosition: Int? = nil
    ) -> TextState {
        
        return .init(text, cursorPosition: cursorPosition ?? text.utf16.count)
    }
}
