//
//  LimitingTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain
import TextFieldModel
import XCTest

final class LimitingTransformerTests: XCTestCase {
    
    func test_transform_limitingTransformerShouldLimit_onLimitLessThanLength() {
        
        let limit = 6
        let transformer = LimitingTransformer(limit)
        let state = TextState("123456789", cursorPosition: 3)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "123456")
        XCTAssertEqual(result.cursorPosition, 3)
        XCTAssertLessThan(limit, state.text.count)
    }
    
    func test_transform_limitingTransformerShouldChangeCursorPosition_onLimitLessThanLength() {
        
        let limit = 6
        let transformer = LimitingTransformer(limit)
        let state = TextState("123456789", cursorPosition: 8)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "123456")
        XCTAssertEqual(result.cursorPosition, 6)
        XCTAssertLessThan(limit, state.text.count)
    }
    
    func test_transform_limitingTransformerShouldNotLimit_onLimitEqualToLength() {
        
        let limit = 9
        let transformer = LimitingTransformer(limit)
        let state = TextState("123456789", cursorPosition: 3)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "123456789")
        XCTAssertEqual(result.cursorPosition, 3)
        XCTAssertEqual(limit, state.text.count)
    }
    
    func test_transform_limitingTransformerShouldNotLimit_onLimitGreaterThanLength() {
        
        let limit = 10
        let transformer = LimitingTransformer(limit)
        let state = TextState("123456789", cursorPosition: 3)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "123456789")
        XCTAssertEqual(result.cursorPosition, 3)
        XCTAssertGreaterThan(limit, state.text.count)
    }
}
