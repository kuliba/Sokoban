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
            { try $0.delete() },
            { try $0.delete() },
            { try $0.delete() },
            { _ in .finishEditing }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("A placeholder"),
            .editing(.empty),
            .editing(.init("+374",   cursorAt: 4)),
            .editing(.init("+37449", cursorAt: 6)),
            .editing(.init("+3744",  cursorAt: 5)),
            .noFocus("+3744"),
            .editing(.init("+3744",  cursorAt: 5)),
            .editing(.init("+374",   cursorAt: 4)),
            .editing(.init("+37",    cursorAt: 3)),
            .editing(.init("+374",   cursorAt: 4)),
            .editing(.init("+37",    cursorAt: 3)),
            .noFocus("+37")
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
            { try $0.delete() },
            { try $0.delete() },
            { _ in .finishEditing }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("A placeholder"),
            .editing(.empty),
            .editing(.init("+374",   cursorAt: 4)),
            .editing(.init("+37449", cursorAt: 6)),
            .editing(.init("+3744",  cursorAt: 5)),
            .noFocus("+3744"),
            .editing(.init("+3744",  cursorAt: 5)),
            .editing(.init("+374",   cursorAt: 4)),
            .editing(.init("+37",    cursorAt: 3)),
            .editing(.init("+3",     cursorAt: 2)),
            .editing(.init("",       cursorAt: 0)),
            .placeholder("A placeholder"),
        ])
    }
}
