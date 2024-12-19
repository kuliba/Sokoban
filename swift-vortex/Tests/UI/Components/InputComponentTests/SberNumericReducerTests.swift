//
//  SberNumericReducerTests.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain
import TextFieldModel
import InputComponent
import XCTest

final class SberNumericReducerTests: XCTestCase {
    
    func test_reduce_shouldReplaceCommaWithPeriod() throws{
        
        try assert(
            .editing(.init("132")),
            .changeText(",", in: .init(location: 3, length: 0)),
            reducesTo: .editing(.init("132."))
        )
    }
    
    func test_reduce_shouldOmitSecondPeriod() throws{
        
        try assert(
            .editing(.init("132")),
            .changeText(",.", in: .init(location: 3, length: 0)),
            reducesTo: .editing(.init("132."))
        )
    }
    
    func test_reduce_shouldRemoveNonDigits() throws{
        
        try assert(
            .editing(.init("a1D&*-32|")),
            .changeText("", in: .init(location: 3, length: 0)),
            reducesTo: .editing(.init("132"))
        )
    }
    
    func test_reduce_shouldRemoveNonDigitsAddPeriodAtCursor() throws{
        
        try assert(
            .editing(.init("a1D&*-32|")),
            .changeText(",", in: .init(location: 3, length: 0)),
            reducesTo: .editing(.init("1.32"))
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TransformingReducer
    
    private func reduce(
        _ state: TextFieldState,
        _ event: TextFieldAction
    ) throws -> TextFieldState {
        
        let sut = TransformingReducer.sberNumericReducer(
            placeholderText: "placeholder"
        )
        
        return try sut.reduce(state, with: event)
    }
    
    private func assert(
        _ state: TextFieldState,
        _ event: TextFieldAction,
        reducesTo expectedState: TextFieldState,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try XCTAssertEqual(
            reduce(state, event),
            expectedState,
            file: file, line: line
        )
    }
}
