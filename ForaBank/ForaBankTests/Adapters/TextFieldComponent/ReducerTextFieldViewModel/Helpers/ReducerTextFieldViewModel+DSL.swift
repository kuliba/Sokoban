//
//  ReducerTextFieldViewModel+DSL.swift
//  VortexTests
//
//  Created by Igor Malyarov on 26.04.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

// MARK: - DSL

extension ReducerTextFieldViewModel {
    
    func insertAtCursor(
        _ text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch state {
        case let .editing(textState):
            self.type(
                "\(text)",
                in: .init(location: textState.cursorPosition, length: 0)
            )
            
        case .noFocus, .placeholder:
            XCTFail("Expected `editing` state, got \(String(describing: state)).", file: file, line: line)
        }
    }
    
    func insert(
        _ text: String,
        atCursor cursorPosition: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch state {
        case .editing:
            self.type(
                "\(text)",
                in: .init(location: cursorPosition, length: 0)
            )
            
        case .noFocus, .placeholder:
            XCTFail("Expected `editing` state, got \(String(describing: state)).", file: file, line: line)
        }
    }
    
    func deleteLast(file: StaticString = #file, line: UInt = #line) {
        
        switch state {
        case let .editing(textState):
            let cursorPosition = max(0, textState.cursorPosition - 1)
            self.type(
                "",
                in: .init(location: cursorPosition, length: 1)
            )
            
        case .noFocus, .placeholder:
            XCTFail("Expected `editing` state, got \(String(describing: state)).", file: file, line: line)
        }
    }
}
