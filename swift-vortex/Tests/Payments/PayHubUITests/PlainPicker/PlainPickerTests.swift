//
//  PlainPickerTests.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import XCTest

class PlainPickerTests: XCTestCase {
    
    struct Element: Equatable {
        
        let value: String
    }
    
    func makeElement(
        _ value: String = anyMessage()
    ) -> Element {
        
        return .init(value: value)
    }
    
    struct Navigation: Equatable {
        
        let value: String
    }
    
    func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
}
