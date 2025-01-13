//
//  TransformerBuilderTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain
import TextFieldModel
import XCTest

final class TransformerBuilderTests: XCTestCase {
    
    func test_builder() {
        
        let transformer = Transform(build: {
            
            LimitingTransformer(6)
            LimitingTransformer(7)
            LimitingTransformer(4)
        })
        
        let state = TextState("123456789", cursorPosition: 3)
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "1234")
        XCTAssertEqual(result.cursorPosition, 3)
        XCTAssertLessThan(4, state.text.count)
    }
    
    func test_builder_shouldReturnEmpty_onInvalidAccountNumber() {
        
        let transformer = Transform(build: {
            
            FilteringTransformer.digits
            RegexTransformer.rubAccountNumber
        })
        
        let state = TextState("12345 000 3333 3333 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result, .empty)
    }
    
    func test_builder_shouldReturnAccount_onValidAccountNumber() {
        
        let transformer = Transform(build: {
            
            FilteringTransformer.digits
            RegexTransformer.rubAccountNumber
        })
        
        let state = TextState("12345 810 3333 3333 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "12345810333333333333")
        XCTAssertEqual(result.cursorPosition, 20)
    }
    
    func test_builder_mix() {
        
        let transformer = Transform(build: {
            
            FilteringTransformer.digits
            LimitingTransformer(5)
            RegexTransformer(regexPattern: #"[3-5]"#)
        })
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333    3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "345")
        XCTAssertEqual(result.cursorPosition, 3)
    }
    
    func test_builder_mix2() {
        
        let transformer = Transform(build: {
            
            FilteringTransformer.letters
            LimitingTransformer(5)
        })
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333    3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "adfgh")
        XCTAssertEqual(result.cursorPosition, 5)
    }
    
    func test_builder_shouldApplyTransformation_onConditionalWithoutElse_true() {
        
        let flag = true
        let transformer = Transform(build: {
            
            if flag {
                FilteringTransformer.letters
            }
        })
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "adfghjkl")
        XCTAssertEqual(result.cursorPosition, 8)
    }
    
    func test_builder_shouldReturnSame_onConditionalWithoutElse_false() {
        
        let flag = false
        let transformer = Transform(build: {
            
            if flag {
                FilteringTransformer.letters
            }
        })
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result, state)
    }
    
    func test_builder_shouldApplyFirstTransformation_onConditional_true() {
        
        let flag = true
        let transformer = Transform(build: {
            
            if flag {
                FilteringTransformer.letters
            } else {
                LimitingTransformer(5)
            }
        })
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "adfghjkl")
        XCTAssertEqual(result.cursorPosition, 8)
    }
    
    func test_builder_shouldApplySecondTransformation_onConditional_false() {
        
        let flag = false
        let transformer = Transform(build: {
            
            if flag {
                FilteringTransformer.letters
            } else {
                LimitingTransformer(5)
            }
        })
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "a 123")
        XCTAssertEqual(result.cursorPosition, 5)
    }
    
    func test_builder_shouldApplyFirstTransformation_onSwitch_one() {
        
        let transformer = switchTransformer(.one)
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "adfghjkl")
        XCTAssertEqual(result.cursorPosition, 8)
    }
    
    func test_builder_shouldApplySecondTransformation_onSwitch_two() {
        
        let transformer = switchTransformer(.two)
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "1234581033333333")
        XCTAssertEqual(result.cursorPosition, 16)
    }
    
    func test_builder_shouldApplyThirdTransformation_onSwitch_three() {
        
        let transformer = switchTransformer(.three)
        
        let state = TextState("a 12345 %^& 810 dfghjkl 3333 ^&* 3333")
        
        let result = transformer.transform(state)
        
        XCTAssertEqual(result.text, "a 123")
        XCTAssertEqual(result.cursorPosition, 5)
    }
    
    private enum TestCase { case one, two, three }
    
    private func switchTransformer(_ testCase: TestCase) -> Transformer {
        
        Transform(build: {
            
            switch testCase {
            case .one:
                FilteringTransformer.letters
            case .two:
                FilteringTransformer.digits
            case .three:
                LimitingTransformer(5)
            }
        })
    }
}
