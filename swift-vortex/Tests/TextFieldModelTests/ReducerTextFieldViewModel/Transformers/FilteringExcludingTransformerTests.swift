//
//  FilteringExcludingTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 25.04.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

extension Set where Element == Character {
    
    static let phoneDecoration: Self = [" ", "-", "+", "(", ")"]
}

final class FilteringExcludingTransformerTests: XCTestCase {
    
    func test_filerExcluding_shouldReturnEmpty_onEmptySet() {
        
        let source = TextState("")
        let excludingCharacters: Set<Character> = []
        
        let excludingFilter = makeSUT(excludingCharacters)
        let filtered = excludingFilter.transform(source)
        
        XCTAssertNoDiff(source, .empty)
        XCTAssertNoDiff(filtered, .empty)
        XCTAssertNoDiff(excludingCharacters, [])
    }

    func test_filerExcluding_shouldReturnSame_onEmptySet() {
        
        let source = TextState("ab cde")
        let excludingCharacters: Set<Character> = []
        
        let excludingFilter = makeSUT(excludingCharacters)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(filtered, source)
        XCTAssertNoDiff(excludingCharacters, [])
        XCTAssertTrue(excludingCharacters.isEmpty)
    }
    
    func test_filerExcluding_shouldReturnEmpty_onEmpty() {
        
        let source = TextState("")
        let excludingCharacters: Set<Character> = [" ", "b", "d"]
        
        let excludingFilter = makeSUT(excludingCharacters)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(source, .empty)
        XCTAssertNoDiff(filtered, .empty)
    }

    func test_filerExcluding_shouldReturnEmpty_onOneInSet() {
        
        let source = TextState("a")
        let excludingCharacters: Set<Character> = ["a"]
        
        let excludingFilter = makeSUT(excludingCharacters)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(filtered, .empty)
        XCTAssertEqual(excludingCharacters.count, 1)
    }

    func test_filerExcluding_shouldReturnSame_onOneNotInSet() {
        
        let source = TextState("a")
        let excludingCharacters: Set<Character> = ["b"]
        
        let excludingFilter = makeSUT(excludingCharacters)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(filtered, .init("a"))
        XCTAssertEqual(excludingCharacters.count, 1)
    }
    
    func test_filerExcluding_shouldFilterIfPresent() throws {
        
        let source = TextState("ab cde", cursorPosition: 3)
        let excludingCharacters: Set<Character> = [" ", "b", "d"]
        
        let excludingFilter = makeSUT(excludingCharacters)
        let filtered = excludingFilter.transform(source)

        try assertTextState(filtered, hasText: "ace", beforeCursor: "ace", afterCursor: "")
    }
    
    func test_filerExcluding_shouldReturnSameIfNotPresent() {
        
        let source = TextState("ab cde", cursorPosition: 3)
        let excludingCharacters: Set<Character> = ["w", "m"]
        
        let excludingFilter = makeSUT(excludingCharacters)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(filtered, source)
    }
    
    func test_filerExcluding_shouldRemoveSpaces_phoneDecoration() throws {
                
        let source = TextState(" ab cde ", cursorPosition: 2)
        
        let excludingFilter = makeSUT(.phoneDecoration)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(filtered, .init("abcde"))
        try assertTextState(filtered, hasText: "abcde", beforeCursor: "abcde", afterCursor: "")
    }
    
    func test_filerExcluding_shouldRemoveDashes_phoneDecoration() throws {
                
        let source = TextState("-ab-cde-", cursorPosition: 3)
        
        let excludingFilter = makeSUT(.phoneDecoration)
        let filtered = excludingFilter.transform(source)

        try assertTextState(filtered, hasText: "abcde", beforeCursor: "abcde", afterCursor: "")
    }
    
    func test_filerExcluding_shouldRemovePluses_phoneDecoration() throws {
                
        let source = TextState("+ab+cde+", cursorPosition: 3)
        
        let excludingFilter = makeSUT(.phoneDecoration)
        let filtered = excludingFilter.transform(source)

        try assertTextState(filtered, hasText: "abcde", beforeCursor: "abcde", afterCursor: "")
    }
    
    func test_filerExcluding_shouldRemoveOpenBrace_phoneDecoration() throws {
                
        let source = TextState("(ab(cde(", cursorPosition: 3)
        
        let excludingFilter = makeSUT(.phoneDecoration)
        let filtered = excludingFilter.transform(source)

        try assertTextState(filtered, hasText: "abcde", beforeCursor: "abcde", afterCursor: "")
    }
    
    func test_filerExcluding_shouldRemoveCloseBrace_phoneDecoration() {
                
        let source = TextState(")ab)cde)")
        
        let excludingFilter = makeSUT(.phoneDecoration)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(filtered, .init("abcde"))
    }
    
    func test_filerExcluding_shouldRemoveMultiple_phoneDecoration() {
                
        let source = TextState("(+-)ab(-+)cde(+-)")
        
        let excludingFilter = makeSUT(.phoneDecoration)
        let filtered = excludingFilter.transform(source)

        XCTAssertNoDiff(filtered, .init("abcde"))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        _ excludingCharacters: Set<Character> = []
    ) -> FilteringExcluding {
        
        FilteringExcluding(excludingCharacters: excludingCharacters)
    }
}
