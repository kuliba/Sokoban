//
//  RegexTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class RegexTransformerTests: XCTestCase {
    
    func test_transform_regexTransformer() {
        
        let state = TextState("123456789", cursorPosition: 3)
        let regex = #"[3-6]"#
        let transformer = RegexTransformer(regexPattern: regex)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "3456")
        XCTAssertEqual(result.cursorPosition, 4)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onEmpty() {
        
        let state = TextState("")
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.view, .init("", cursorAt: 0))
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnOne_onOne() {
        
        let state = TextState("1", cursorPosition: 0)
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "1")
        XCTAssertEqual(result.cursorPosition, 1)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnTwo_onTwo() {
        
        let state = TextState("12", cursorPosition: 1)
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "12")
        XCTAssertEqual(result.cursorPosition, 2)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onDigithsInMiddle() {
        
        let state = TextState("abc 1234 defgh", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.view, .init("", cursorAt: 0))
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnThree_onThree() {
        
        let state = TextState("123", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "123")
        XCTAssertEqual(result.cursorPosition, 3)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onFour() {
        
        let state = TextState("1234", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.view, .init("", cursorAt: 0))
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onFirstLetter() {
        
        let state = TextState("a1234", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.view, .init("", cursorAt: 0))
    }
    
    // MARK: - rubAccountNumber
    
    func test_rubAccountNumberRegexTransformer_shouldReturnNil_onInvalid1() {
        
        let state = TextState("a1234")
        let transformer = RegexTransformer.rubAccountNumber
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.view, .init("", cursorAt: 0))
    }
    
    func test_rubAccountNumberRegexTransformer_shouldReturnNil_onInvalid2() {
        
        let state = TextState("12345 000 3333 3333 3333")
        let transformer = RegexTransformer.rubAccountNumber
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.view, .init("", cursorAt: 0))
    }
    
    func test_rubAccountNumberRegexTransformer_shouldReturnSame_onValid() {
        
        let account = "12345810333333333333"
        let state = TextState(account)
        let transformer = RegexTransformer.rubAccountNumber
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.view, .init(account, cursorAt: 20))
    }
}
