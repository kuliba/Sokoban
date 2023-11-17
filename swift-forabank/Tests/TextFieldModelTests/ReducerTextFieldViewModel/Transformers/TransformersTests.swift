//
//  TransformersTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class TransformersTests: XCTestCase {
    
    // MARK: - countryCodeSubstitute
    
    private let substitutions: [CountryCodeSubstitution] = [
        
        .init(from: "89", to: "+79"),
    ]
    
    func test_replace_shouldNotChangeState_onSubstitutionMismatch() {
        
        let transformer = Transformers.countryCodeSubstitute(substitutions)
        let state = TextState("a", cursorPosition: 0)
        
        let changed = transformer.transform(state)
        
        assertTextState(changed, hasText: "a", cursorAt: 0)
    }
    
    func test_replace_shouldNotChangeState_onSubstitutionMismatch2() {
        
        let transformer = Transformers.countryCodeSubstitute(substitutions)
        let state = TextState("a", cursorPosition: 1)
        
        let changed = transformer.transform(state)
        
        assertTextState(changed, hasText: "a", cursorAt: 1)
    }
    
    func test_replace_shouldChangeState_onSubstitutionMatch() {
        
        let transformer = Transformers.countryCodeSubstitute(substitutions)
        let state = TextState("3", cursorPosition: 1)
        
        let changed = transformer.transform(state)
        
        assertTextState(changed, hasText: "3", cursorAt: 1)
    }
    
    func test_replace_shouldChangeState_onSubstitutionMatch2() {
        
        let transformer = Transformers.countryCodeSubstitute(substitutions)
        let state = TextState("89", cursorPosition: 2)
        
        let changed = transformer.transform(state)
        
        assertTextState(changed, hasText: "+79", cursorAt: 3)
    }
    
    func test_replace_shouldChangeState_onSubstitutionMatch3() {
        
        let transformer = Transformers.countryCodeSubstitute(substitutions)
        let state = TextState("9", cursorPosition: 1)
        
        let changed = transformer.transform(state)
        
        assertTextState(changed, hasText: "9", cursorAt: 1)
    }
    
    // MARK: - filtering
    
    func test_filtering_shouldReturnEmpty_onMissing() {
        
        let state = TextState("abcde", cursorPosition: 3)
        let transformer = FilteringTransformer(with: .init(["A"]))
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    // MARK: filtering digits
    
    func test_digits_shouldReturnEmpty_onNonNumbers() {
        
        let state = TextState("@#$%^&*(DCVBNKMl,/.,mbwdsvcf", cursorPosition: 3)
        let transformer = Transformers.filtering(with: .decimalDigits)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_digits_shouldReturnSame_onNumbersOnly() {
        
        let state = TextState("0123456789", cursorPosition: 3)
        let transformer = Transformers.filtering(with: .decimalDigits)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "0123456789", cursorAt: 10)
        XCTAssertEqual(result.text.count, 10)
    }
    
    func test_digits_shouldReturnSame_onNumbersOnly_reversed() {
        
        let state = TextState(.init("0123456789".reversed()), cursorPosition: 3)
        let transformer = Transformers.filtering(with: .decimalDigits)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "9876543210", cursorAt: 10)
        XCTAssertEqual(result.text.count, 10)
    }
    
    func test_digits_shouldRemoveNonNumbers() {
        
        let state = TextState("0abc123%^&456789", cursorPosition: 3)
        let transformer = Transformers.filtering(with: .decimalDigits)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "0123456789", cursorAt: 10)
        XCTAssertEqual(result.text.count, 10)
    }
    
    // MARK: filtering letters
    
    func test_letters_shouldReturnEmpty_onNonLetters() {
        
        let state = TextState("@#$%^&*(1234567890-", cursorPosition: 3)
        let transformer = Transformers.filtering(with: .letters)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
        XCTAssertEqual(result.text.count, 0)
    }
    
    func test_letters_shouldReturnSame_onLettersOnly() {
        
        let state = TextState("asPOIUdfghjkl", cursorPosition: 3)
        let transformer = Transformers.filtering(with: .letters)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "asPOIUdfghjkl", cursorAt: 13)
        XCTAssertEqual(result.text.count, 13)
    }
    
    func test_letters_shouldRemoveNonLetters_onLettersOnly() {
        
        let state = TextState("a$%^&sPOIU345678dfghjkl", cursorPosition: 3)
        let transformer = Transformers.filtering(with: .letters)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "asPOIUdfghjkl", cursorAt: 13)
        XCTAssertEqual(result.text.count, 13)
    }
    
    // MARK: - filtering: excluding characters
    
    func test_excluding_shouldReturnSameOnEmptyExcluding() {
        
        let state = TextState("a-b/c)d(f", cursorPosition: 3)
        let transformer = Transformers.filtering(excluding: [])
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: state.text, cursorAt: state.cursorPosition)
    }
    
    func test_excluding_shouldRemoveCharacter() {
        
        let state = TextState("a-b/c)d(f", cursorPosition: 3)
        let transformer = Transformers.filtering(excluding: ["-"])
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "ab/c)d(f", cursorAt: 8)
        XCTAssertEqual(result.text.count, 8)
    }
    
    func test_excluding_shouldRemoveCharacters() {
        
        let state = TextState("a-b/c)d(f", cursorPosition: 3)
        let transformer = Transformers.filtering(excluding: ["-", "(", ")", "/"])
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "abcdf", cursorAt: 5)
        XCTAssertEqual(result.text.count, 5)
    }
    
    // MARK: - limiting
    
    func test_transform_limitingTransformerShouldLimit_onLimitLessThanLength() {
        
        let limit = 6
        let transformer = Transformers.limiting(limit)
        let state = TextState("123456789", cursorPosition: 3)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "123456", cursorAt: 3)
        XCTAssertLessThan(limit, state.text.count)
    }
    
    func test_transform_limitingTransformerShouldChangeCursorPosition_onLimitLessThanLength() {
        
        let limit = 6
        let transformer = Transformers.limiting(limit)
        let state = TextState("123456789", cursorPosition: 8)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "123456", cursorAt: 6)
        XCTAssertLessThan(limit, state.text.count)
    }
    
    func test_transform_limitingTransformerShouldNotLimit_onLimitEqualToLength() {
        
        let limit = 9
        let transformer = Transformers.limiting(limit)
        let state = TextState("123456789", cursorPosition: 3)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "123456789", cursorAt: 3)
        XCTAssertEqual(limit, state.text.count)
    }
    
    func test_transform_limitingTransformerShouldNotLimit_onLimitGreaterThanLength() {
        
        let limit = 10
        let transformer = Transformers.limiting(limit)
        let state = TextState("123456789", cursorPosition: 3)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "123456789", cursorAt: 3)
        XCTAssertGreaterThan(limit, state.text.count)
    }
    
    // MARK: - regex
    
    func test_transform_regexTransformer() {
        
        let state = TextState("123456789", cursorPosition: 3)
        let regex = #"[3-6]"#
        let transformer = RegexTransformer(regexPattern: regex)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "3456", cursorAt: 4)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onEmpty() {
        
        let state = TextState("")
        let pattern = #"^\d{0,3}$"#
        let transformer = Transformers.regex(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnOne_onOne() {
        
        let state = TextState("1", cursorPosition: 0)
        let pattern = #"^\d{0,3}$"#
        let transformer = Transformers.regex(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "1", cursorAt: 1)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnTwo_onTwo() {
        
        let state = TextState("12", cursorPosition: 1)
        let pattern = #"^\d{0,3}$"#
        let transformer = Transformers.regex(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "12", cursorAt: 2)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onDigithsInMiddle() {
        
        let state = TextState("abc 1234 defgh", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = Transformers.regex(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnThree_onThree() {
        
        let state = TextState("123", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = Transformers.regex(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "123", cursorAt: 3)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onFour() {
        
        let state = TextState("1234", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = Transformers.regex(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_regexTransformer_startsWithUpToThreeDigits_shouldReturnEmpty_onFirstLetter() {
        
        let state = TextState("a1234", cursorPosition: 3)
        let pattern = #"^\d{0,3}$"#
        let transformer = Transformers.regex(regexPattern: pattern)
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    // MARK: - formatter
    
    func test_formatter_shouldChangeStateWithFormattedTextCursorAtEnd() {
        
        let state = TextState("abc123", cursorPosition: 3)
        let transformer = Transformers.formatter { $0.uppercased() }
        
        let result = transformer.transform(state)
        
        assertTextState(result, hasText: "ABC123", cursorAt: 6)
    }
    
    // MARK: - phone
    
    let phoneTransformer = Transformers.testPhone
    let filteringPhoneTransformer = Transformers.filteringTestPhone
    
    func test_phone_emptyShouldNotChange() {
        
        let state: TextState = .empty
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_phone_letterShouldBeFiltered() {
        
        let state: TextState = .init("a", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_phone_textShouldBeFiltered() {
        
        let state: TextState = .init("abc", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_phone_textMixedWithNumbersShouldBeFiltered() {
        
        let state: TextState = .init("12a3bc4", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+1234", cursorAt: 5)
    }
    
    func test_phone_nonNumbersMixedWithNumbersShouldBeFiltered() {
        
        let state: TextState = .init("1$2%a3`b-c4", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+1234", cursorAt: 5)
    }
    
    func test_phone_matchShouldBeSubstituted() {
        
        let state: TextState = .init("3", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+3", cursorAt: 2)
    }
    
    func test_phone_partialMatchShouldNotBeSubstituted() {
        
        let state: TextState = .init("34", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+34", cursorAt: 3)
    }
    
    func test_phone_partialMatchShouldNotBeSubstituted2() {
        
        let state: TextState = .init("37", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+37", cursorAt: 3)
    }
    
    func test_filteringPhone_partialFormattedMatchShouldSubstitute() {
        
        let state: TextState = .init("+3", cursorPosition: 1)
        
        let result = filteringPhoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+3", cursorAt: 2)
    }
    
    func test_phone_partialFormattedMatchShouldNotBeSubstituted3() {
        
        let state: TextState = .init("+3", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+3", cursorAt: 2)
    }
    
    func test_phone_nonMatchShouldNotBeSubstituted() {
        
        let state: TextState = .init("4", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+4", cursorAt: 2)
    }
    
    func test_phone_shouldLimit() {
        
        let state: TextState = .init("1234567", cursorPosition: 1)
        
        let result = phoneTransformer.transform(state)
        
        assertTextState(result, hasText: "+12345", cursorAt: 6)
    }
    
    // MARK: reduce series of actions
    
    func test_reduce_seriesOfActions_filtering() throws {
        
        let transformer = Transformers.filteringTestPhone
        
        let result = try transformer.reduce(
            .empty,
            with: { $0.insertAtCursor("3") },
            { $0.insertAtCursor("49") },
            { try $0.deleteBeforeCursor() },
            { try $0.deleteBeforeCursor() },
            { try $0.deleteBeforeCursor() }
        )
        
        XCTAssertNoDiff(result.map { View($0.text, $0.cursorPosition) }, [
            .init("", 0),
            .init("+3", 2),
            .init("+349", 4),
            .init("+34", 3),
            .init("+3", 2),
            .init("", 0)
        ])
    }
    
    func test_reduce_seriesOfActions() throws {
        
        let transformer = Transformers.testPhone
        
        let result = try transformer.reduce(
            .empty,
            with: { $0.insertAtCursor("3") },
            { $0.insertAtCursor("49") },
            { try $0.deleteBeforeCursor() },
            { try $0.deleteBeforeCursor() },
            { try $0.deleteBeforeCursor() }
        )
        
        XCTAssertNoDiff(result.map { View($0.text, $0.cursorPosition) }, [
            .init("", 0),
            .init("+3", 2),
            .init("+349", 4),
            .init("+34", 3),
            .init("+3", 2),
            .init("", 0)
        ])
    }
    
    private struct View: Equatable {
        
        let text: String
        let cursor: Int

        init(_ text: String, _ cursor: Int) {
            
            self.text = text
            self.cursor = cursor
        }
    }
    
    // MARK: phone without formatter
    
    let phoneNoFormatTransformer = Transformers.phone(
        filterSymbols: [],
        substitutions: .test,
        format: { $0 },
        limit: 6
    )
    
    func test_phoneNoFormatTransformer_emptyShouldNotChange() {
        
        let state: TextState = .empty
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_phoneNoFormatTransformer_letterShouldBeFiltered() {
        
        let state: TextState = .init("a", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_phoneNoFormatTransformer_textShouldBeFiltered() {
        
        let state: TextState = .init("abc", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "", cursorAt: 0)
    }
    
    func test_phoneNoFormatTransformer_textMixedWithNumbersShouldBeFiltered() {
        
        let state: TextState = .init("12a3bc4", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "1234", cursorAt: 4)
    }
    
    func test_phoneNoFormatTransformer_nonNumbersMixedWithNumbersShouldBeFiltered() {
        
        let state: TextState = .init("1$2%a3`b-c4", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "1234", cursorAt: 4)
    }
    
    func test_phoneNoFormatTransformer_matchShouldBeSubstituted() {
        
        let state: TextState = .init("3", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "3", cursorAt: 1)
    }
    
    func test_phoneNoFormatTransformer_partialMatchShouldNotBeSubstituted() {
        
        let state: TextState = .init("34", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "34", cursorAt: 2)
    }
    
    func test_phoneNoFormatTransformer_partialMatchShouldNotBeSubstituted2() {
        
        let state: TextState = .init("37", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "37", cursorAt: 2)
    }
    
    func test_phoneNoFormatTransformer_nonMatchShouldNotBeSubstituted() {
        
        let state: TextState = .init("4", cursorPosition: 1)
        
        let result = phoneNoFormatTransformer.transform(state)
        
        assertTextState(result, hasText: "4", cursorAt: 1)
    }
}
