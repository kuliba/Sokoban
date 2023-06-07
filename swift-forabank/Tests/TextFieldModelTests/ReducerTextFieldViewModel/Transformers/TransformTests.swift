//
//  TransformTests.swift
//
//
//  Created by Igor Malyarov on 17.05.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class TransformTests: XCTestCase {
    
    func test_shouldSubstituteReplacementText() throws {
        
        let transformer = Transform { state in
            let text = Array(repeating: "*", count: state.text.count).joined()
            
            return .init(text)
        }
        
        let state = TextState("Abcde")
        let range = NSRange(location: 2, length: 2)
        let replacementText = "12345"
        
        let changed = try state.replace(inRange: range, with: replacementText)
        
        XCTAssertNoDiff(changed.view, .init("Ab12345e", cursorAt: 7))
        
        let result = transformer.transform(changed)
        
        XCTAssertNoDiff(result.view, .init("********", cursorAt: 8))
    }
        
    func test_shouldFilterReplacementText_onFilteringPreTransformer() throws {
        
        let transformer = FilteringTransformer.letters
        let state = TextState("Abcde")
        let range = NSRange(location: 2, length: 2)
        let replacementText = "12345"
        
        let changed = try state.replace(inRange: range, with: replacementText)

        XCTAssertNoDiff(changed.view, .init("Ab12345e", cursorAt: 7))
        
        let result = transformer.transform(changed)
        
        XCTAssertNoDiff(result.view, .init("Abe", cursorAt: 3))
    }
    
    func test_uppercasing_shouldChangeOutputText() throws {
        
        let transformer = Transform {
            .init(
                $0.text.uppercased(),
                cursorPosition: $0.cursorPosition
            )
        }
        let state = TextState("0123456789", cursorPosition: 3)
        let range = NSRange(location: 3, length: 5)
        let replacementText = "abc"
        
        let changed = try state.replace(inRange: range, with: replacementText)

        XCTAssertNoDiff(changed.view, .init("012abc89", cursorAt: 6))
        
        let result = transformer.transform(changed)
        
        XCTAssertNoDiff(result.view, .init("012ABC89", cursorAt: 6))
    }
    
    // MARK: - Identity Transformer
    
    func test_identity_shouldReturnSame() {
        
        let state = TextState("abcde123")
        let transformer = Transform.identity
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result, state)
    }
    
    func test_identity_shouldReturnSame2() {
        
        let state = TextState("abcde123", cursorPosition: 3)
        let transformer = Transform.identity
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result, state)
    }
}
