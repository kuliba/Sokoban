//
//  PhoneTransformingReducerTests.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

@testable import TextFieldModel
import XCTest

final class PhoneTransformingReducerTests: XCTestCase {
    
    func test_reduce_seriesOfActions_filtering() throws {
        
        let reducer = TransformingReducer(
            placeholderText: "A placeholder",
            transformer: Transformers.filteringTestPhone
        )
        let result = try reducer.reduce(
            .placeholder("A placeholder"),
            actions: { _ in .startEditing },
            { try $0.insert("3") },
            { try $0.insert("49") },
            { try $0.delete() },
            { _ in .finishEditing },
            { _ in .startEditing },
            { try $0.delete() },
            { _ in .finishEditing }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("A placeholder"),
            .editing(.empty),
            .editing(.init("+3",   cursorAt: 2)),
            .editing(.init("+349", cursorAt: 4)),
            .editing(.init("+34",  cursorAt: 3)),
            .noFocus("+34"),
            .editing(.init("+34",  cursorAt: 3)),
            .editing(.init("+3",   cursorAt: 2)),
            .noFocus("+3")
        ])
    }
    
    func test_reduce_seriesOfActions() throws {
        
        let reducer = TransformingReducer(
            placeholderText: "A placeholder",
            transformer: Transformers.testPhone
        )
        let result = try reducer.reduce(
            .placeholder("A placeholder"),
            actions: { _ in .startEditing },
            { try $0.insert("3") },
            { try $0.insert("49") },
            { try $0.delete() },
            { _ in .finishEditing },
            { _ in .startEditing },
            { try $0.delete() },
            { try $0.delete() },
            { _ in .finishEditing }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("A placeholder"),
            .editing(.empty),
            .editing(.init("+3",   cursorAt: 2)),
            .editing(.init("+349", cursorAt: 4)),
            .editing(.init("+34",  cursorAt: 3)),
            .noFocus("+34"),
            .editing(.init("+34",  cursorAt: 3)),
            .editing(.init("+3",   cursorAt: 2)),
            .editing(.init("",    cursorAt: 0)),
            .placeholder("A placeholder"),
        ])
    }
}
