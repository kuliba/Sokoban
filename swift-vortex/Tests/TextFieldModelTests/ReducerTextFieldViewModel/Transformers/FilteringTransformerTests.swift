//
//  FilteringTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain
import TextFieldModel
import XCTest

final class FilteringTransformerTests: XCTestCase {
    
    func test_filtering_shouldReturnEmpty_onMissing() {
        
        let state = TextState("abcde", cursorPosition: 3)
        let transformer = Transformers.filtering(with: .init(["A"]))
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result, .empty)
    }
    
    // MARK: - digits
    
    func test_digits_shouldReturnEmpty_onNonNumbers() {
        
        let state = TextState("@#$%^&*(DCVBNKMl,/.,mbwdsvcf", cursorPosition: 3)
        let transformer = FilteringTransformer.digits
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result, .empty)
    }
    
    func test_digits_shouldReturnSame_onNumbersOnly() {
        
        let state = TextState("0123456789", cursorPosition: 3)
        let transformer = FilteringTransformer.digits
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "0123456789")
        XCTAssertEqual(result.cursorPosition, 10)
        XCTAssertEqual(result.text.count, 10)
    }
    
    func test_digits_shouldReturnSame_onNumbersOnly_reversed() {
        
        let state = TextState(.init("0123456789".reversed()), cursorPosition: 3)
        let transformer = FilteringTransformer.digits
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "9876543210")
        XCTAssertEqual(result.cursorPosition, 10)
        XCTAssertEqual(result.text.count, 10)
    }
    
    func test_digits_shouldRemoveNonNumbers() {
        
        let state = TextState("0abc123%^&456789", cursorPosition: 3)
        let transformer = FilteringTransformer.digits
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "0123456789")
        XCTAssertEqual(result.cursorPosition, 10)
        XCTAssertEqual(result.text.count, 10)
    }
    
    // MARK: - letters
    
    func test_letters_shouldReturnEmpty_onNonLetters() {
        
        let state = TextState("@#$%^&*(1234567890-", cursorPosition: 3)
        let transformer = FilteringTransformer.letters
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "")
        XCTAssertEqual(result.cursorPosition, 0)
        XCTAssertEqual(result.text.count, 0)
    }
    
    func test_letters_shouldReturnSame_onLettersOnly() {
        
        let state = TextState("asPOIUdfghjkl", cursorPosition: 3)
        let transformer = FilteringTransformer.letters
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "asPOIUdfghjkl")
        XCTAssertEqual(result.cursorPosition, 13)
        XCTAssertEqual(result.text.count, 13)
    }
    
    func test_letters_shouldRemoveNonLetters_onLettersOnly() {
        
        let state = TextState("a$%^&sPOIU345678dfghjkl", cursorPosition: 3)
        let transformer = FilteringTransformer.letters
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "asPOIUdfghjkl")
        XCTAssertEqual(result.cursorPosition, 13)
        XCTAssertEqual(result.text.count, 13)
    }
    
    // MARK: numeric
    
    func test_numeric_shouldNotChangeValid() {
        
        let state = TextState("123,.45", cursorPosition: 3)
        let transformer = FilteringTransformer.numeric
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, state.text)
    }
    
    func test_numeric_shouldSetCursorToEndOnValid() {
        
        let state = TextState("123,.45", cursorPosition: 3)
        let transformer = FilteringTransformer.numeric
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.cursorPosition, 7)
    }
    
    func test_numeric_shouldRemoveNonDigitsSetCursorToEnd() {
        
        let state = TextState("aD1vb23,$.4&5-", cursorPosition: 3)
        let transformer = FilteringTransformer.numeric
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "123,.45")
        XCTAssertEqual(result.cursorPosition, 7)
    }
}
