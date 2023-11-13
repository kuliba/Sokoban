//
//  CodeStateTests.swift
//  
//
//  Created by Andryusina Nataly on 17.07.2023.
//
@testable import PinCodeUI

import XCTest

final class CodeStateTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_empty_shouldSetAllValue() {
        
        let state: CodeState = .init(
            state: .empty,
            title: "title"
        )
        
        XCTAssertEqual(state.state, .empty)
        XCTAssertEqual(state.firstValue, "")
        XCTAssertEqual(state.confirmValue, "")
        XCTAssertEqual(state.currentStyle, .normal)
        XCTAssertEqual(state.title, "title")
        XCTAssertEqual(state.titleForView, "title")
    }
    
    func test_init_first_shouldSetAllValue() {
        
        let state: CodeState = .init(
            state: .firstSet(first: "first"),
            title: "title"
        )
        
        XCTAssertEqual(state.state, .firstSet(first: "first"))
        XCTAssertEqual(state.firstValue, "first")
        XCTAssertEqual(state.confirmValue, "")
        XCTAssertEqual(state.currentStyle, .printing)
        XCTAssertEqual(state.title, "title")
        XCTAssertEqual(state.titleForView, "title")
    }

    func test_init_second_shouldSetAllValue() {
        
        let state: CodeState = .init(
            state: .confirmSet(first: "1", second: "2"),
            title: "title"
        )
        
        XCTAssertEqual(state.state, .confirmSet(first: "1", second: "2"))
        XCTAssertEqual(state.firstValue, "1")
        XCTAssertEqual(state.confirmValue, "2")
        XCTAssertEqual(state.currentStyle, .printing)
        XCTAssertEqual(state.title, "title")
        XCTAssertEqual(state.titleForView, "Подтвердите PIN-код\n")
    }
    
    func test_init_check_incorrect_shouldSetAllValue() {
        
        let state: CodeState = .init(
            state: .checkValue(first: "1", second: "2"),
            title: "title"
        )
        
        XCTAssertEqual(state.state, .checkValue(first: "1", second: "2"))
        XCTAssertEqual(state.firstValue, "1")
        XCTAssertEqual(state.confirmValue, "2")
        XCTAssertEqual(state.currentStyle, .incorrect)
        XCTAssertEqual(state.title, "title")
        XCTAssertEqual(state.titleForView, "Подтвердите PIN-код\n")
    }

    func test_init_check_correct_shouldSetAllValue() {
        
        let state: CodeState = .init(
            state: .checkValue(first: "1", second: "1"),
            title: "title"
        )
        
        XCTAssertEqual(state.state, .checkValue(first: "1", second: "1"))
        XCTAssertEqual(state.firstValue, "1")
        XCTAssertEqual(state.confirmValue, "1")
        XCTAssertEqual(state.currentStyle, .correct)
        XCTAssertEqual(state.title, "title")
        XCTAssertEqual(state.titleForView, "Подтвердите PIN-код\n")
    }
    
    //MARK: - test update
    
    func test_updateState_shouldSetAllValue() {
        
        var state: CodeState = .init(
            state: .firstSet(first: "first"),
            title: "title"
        )
        
        XCTAssertEqual(state.state, .firstSet(first: "first"))
        XCTAssertEqual(state.firstValue, "first")
        XCTAssertEqual(state.confirmValue, "")
        XCTAssertEqual(state.currentStyle, .printing)
        XCTAssertEqual(state.title, "title")
        XCTAssertEqual(state.titleForView, "title")
        
        state.updateState(.confirmSet(first: "first", second: "2"), newCode: "2")
        
        XCTAssertEqual(state.state, .confirmSet(first: "first", second: "2"))
        XCTAssertEqual(state.firstValue, "first")
        XCTAssertEqual(state.confirmValue, "2")
        XCTAssertEqual(state.code, "2")
        XCTAssertEqual(state.currentStyle, .printing)
        XCTAssertEqual(state.title, "title")
        XCTAssertEqual(state.titleForView, "Подтвердите PIN-код\n")
    }
}
