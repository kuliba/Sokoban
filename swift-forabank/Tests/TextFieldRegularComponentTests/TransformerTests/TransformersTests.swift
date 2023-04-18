//
//  TransformersTests.swift
//  
//
//  Created by Igor Malyarov on 15.04.2023.
//

//@testable
import TextFieldRegularComponent
import XCTest

final class TransformersTests: XCTestCase {
    
    // MARK: - AnyTransformer
    
    func test_AnyTransformer_shouldLimit_onLimitLessThanInputLength() {
        
        let input = "123456789"
        let limit = 6
        let transformer = AnyTransformer(limit: limit, regex: nil)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "123456")
        XCTAssertLessThan(limit, input.count)
    }
    
    func test_AnyTransformer_shouldNotLimit_onLimitEqualToInputLength() {
        
        let input = "123456789"
        let limit = 9
        let transformer = AnyTransformer(limit: limit, regex: nil)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "123456789")
        XCTAssertEqual(limit, input.count)
    }
    
    func test_AnyTransformer_shouldNotLimit_onLimitGreaterThanInputLength() {
        
        let input = "123456789"
        let limit = 10
        let transformer = AnyTransformer(limit: limit, regex: nil)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "123456789")
        XCTAssertGreaterThan(limit, input.count)
    }
    
    func test_AnyTransformer_withRegex() {
        
        let input = "123456789"
        let regex = #"[3-6]"#
        let transformer = AnyTransformer(limit: nil, regex: regex)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "3456")
    }
    
    // MARK: - FilteringTransformer
    
    func test_numbers_shouldReturnEmpty_onNonNumbers() {
        
        let input = "@#$%^&*(DCVBNKMl,/.,mbwdsvcf"
        let result = FilteringTransformer.numbers.transform(input)
        
        XCTAssertEqual(result, "")
    }
    
    func test_numbers_shouldReturnSame_onNumbersOnly() {
        
        let input = "0123456789"
        let result = FilteringTransformer.numbers.transform(input)
        
        XCTAssertEqual(result, "0123456789")
    }
    
    func test_numbers_shouldReturnSame_onNumbersOnly_reversed() {
        
        let input = String("0123456789".reversed())
        let result = FilteringTransformer.numbers.transform(input)
        
        XCTAssertEqual(result, "9876543210")
    }
    
    func test_numbers_shouldRemoveNonNumbers() {
        
        let input = "0abc123%^&456789"
        let result = FilteringTransformer.numbers.transform(input)
        
        XCTAssertEqual(result, "0123456789")
    }
    
    func test_letters_shouldReturnEmpty_onNonLetters() {
        
        let input = "@#$%^&*(1234567890-"
        let result = FilteringTransformer.letters.transform(input)
        
        XCTAssertEqual(result, "")
    }
    
    func test_letters_shouldReturnSame_onLettersOnly() {
        
        let input = "asPOIUdfghjkl"
        let result = FilteringTransformer.letters.transform(input)
        
        XCTAssertEqual(result, "asPOIUdfghjkl")
    }
    
    func test_letters_shouldRemoveNonLetters_onLettersOnly() {
        
        let input = "a$%^&sPOIU345678dfghjkl"
        let result = FilteringTransformer.letters.transform(input)
        
        XCTAssertEqual(result, "asPOIUdfghjkl")
    }
    
    // MARK: - RegexTransformer
    
    func test_regexTransformer_upToThreeDigits_shouldReturnEmpty_onEmpty() {
        
        let input = ""
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "")
    }
    
    func test_regexTransformer_upToThreeDigits_shouldReturnOne_onOne() {
        
        let input = "1"
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "1")
    }
    
    func test_regexTransformer_upToThreeDigits_shouldReturnTwo_onTwo() {
        
        //let input = "abc 1234 defgh"
        let input = "12"
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "12")
    }
    
    func test_regexTransformer_upToThreeDigits_shouldReturnThree_onThree() {
        
        let input = "123"
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "123")
    }
    
    func test_regexTransformer_upToThreeDigits_shouldReturnEmpty_onFour() {
        
        let input = "1234"
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "")
    }
    
    func test_regexTransformer_upToThreeDigits_shouldReturnEmpty_onFirstLetter() {
        
        let input = "a1234"
        let pattern = #"^\d{0,3}$"#
        let transformer = RegexTransformer(regexPattern: pattern)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "")
    }
    
    // MARK: - ChainedTransformer
    
    func test_rubAccountNumber_shouldReturnEmpty_onBadAccount_chained() {
        
        let input = "12345 000 3333 3333 3333"
        let transformer = ChainedTransformer(
            first: FilteringTransformer.numbers,
            second: RegexTransformer.rubAccountNumber
        )
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "")
    }
    
    func test_rubAccountNumber_shouldReturnSame_onRubAccount_chained() {
        
        let input = "12345 810 3333 3333 3333"
        let transformer = ChainedTransformer(
            first: FilteringTransformer.numbers,
            second: RegexTransformer.rubAccountNumber
        )
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "12345810333333333333")
    }
    
    func test_rubAccountNumber_shouldReturnSame_onRubAccount_chained2() {
        
        let input = "12345 810 3333 3333 3333"
        let regexTransformer = RegexTransformer.rubAccountNumber
        let transformer = FilteringTransformer.numbers
            .chained(with: regexTransformer)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "12345810333333333333")
    }
    
    func test_muliChained() {
        
        let input = "a 12345 %^& 810 dfghjkl 3333 ^&* 3333    3333"
        let transformer = AnyTransformer()
            .numbers()
            .limit(5)
            .regex(pattern: #"[3-5]"#)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "345")
    }
    
    func test_muliChained_letters() {
        
        let input = "a 12345 %^& 810 dfghjkl 3333 ^&* 3333    3333"
        let transformer = AnyTransformer()
            .letters()
            .limit(5)
        
        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "adfgh")
    }
    
    // MARK: - LimitingTransformer
    
    func test_limitingTransformer_shouldLimit_onLess() {
        
        let input = "123456"
        let limit = 5
        let transformer = LimitingTransformer(limit: limit)

        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "12345")
        XCTAssertLessThan(limit, input.count)
    }
    
    func test_limitingTransformer_shouldNotLimit_onLess() {
        
        let input = "123456"
        let limit = 6
        let transformer = LimitingTransformer(limit: limit)

        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "123456")
        XCTAssertEqual(limit, input.count)
    }
    
    func test_limitingTransformer_shouldNotLimit_onGreate() {
        
        let input = "123456"
        let limit = 7
        let transformer = LimitingTransformer(limit: limit)

        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "123456")
        XCTAssertGreaterThan(limit, input.count)
    }
    
    func test_limit_() {
        
        let input = "abc123456"
        let limit = 7
        let transformer = FilteringTransformer.numbers
            .limit(limit)

        let result = transformer.transform(input)
        
        XCTAssertEqual(result, "123456")
    }
}
