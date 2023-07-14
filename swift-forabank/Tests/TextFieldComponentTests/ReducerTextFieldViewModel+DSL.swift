//
//  ReducerTextFieldViewModel+DSL.swift
//  
//
//  Created by Igor Malyarov on 16.05.2023.
//

@testable import TextFieldModel
import XCTest

// MARK: - DSL

extension ReducerTextFieldViewModel {
    
    func startEditing(on scheduler: TestSchedulerOfDispatchQueue) {
        
        startEditing()
        scheduler.advance()
    }
    
    func finishEditing(on scheduler: TestSchedulerOfDispatchQueue) {
        
        finishEditing()
        scheduler.advance()
    }
    
    func replaceWith(
        _ text: String,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        setText(to: text)
        scheduler.advance()
    }
    
    func deleteLast(file: StaticString = #file, line: UInt = #line) {
        
        switch state {
        case let .editing(textState):
            let cursorPosition = max(0, textState.cursorPosition - 1)
            let range = NSRange(location: cursorPosition, length: 1)
            self.type("", in: range)
            
        case .noFocus, .placeholder:
            XCTFail("Expected `editing` state, got \(String(describing: state)).", file: file, line: line)
        }
    }
}
