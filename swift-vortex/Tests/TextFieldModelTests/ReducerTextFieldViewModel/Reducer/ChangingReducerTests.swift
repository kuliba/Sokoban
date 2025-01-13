//
//  ChangingReducerTests.swift
//  
//
//  Created by Igor Malyarov on 26.05.2023.
//

@testable import TextFieldModel
import XCTest

final class ChangingReducerTests: XCTestCase {
    
    // MARK: - digitFiltering
    
    let digitFiltering = Reducers.digitFiltering(placeholderText: "A placeholder")
    
    func test_digitFiltering_shouldFilterDigits_empty_paste() throws {
        
        let result = try digitFiltering.reduce(
            .editing(.empty),
            actions: { try $0.paste("ab12cde345") }
        )
        
        XCTAssertNoDiff(result, [
            .editing(.empty),
            .editing(.init("12345", cursorAt: 5))
        ])
    }
    
    func test_digitFiltering_shouldFilterDigits_nonEmpty_paste() throws {
        
        let result = try digitFiltering.reduce(
            .editing(.init("ABCDE", cursorAt: 2)),
            actions: { try $0.paste("ab12cde345") }
        )
        
        XCTAssertNoDiff(result, [
            .editing(.init("ABCDE", cursorAt: 2)),
            .editing(.init("12345", cursorAt: 5))
        ])
    }
    
    func test_digitFiltering_shouldFilterDigits_nonEmpty_insert() throws {
        
        let result = try digitFiltering.reduce(
            .editing(.init("ABCDE", cursorAt: 2)),
            actions: { try $0.replace(count: 2, with: "ab12cde345") }
        )
        
        XCTAssertNoDiff(result, [
            .editing(.init("ABCDE", cursorAt: 2)),
            .editing(.init("AB12345E", cursorAt: 7))
        ])
    }
}
