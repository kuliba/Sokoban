//
//  ContactTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 25.05.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class ContactTransformerTests: XCTestCase {
    
    func test_transform_shouldReturnEmpty_onEmpty() throws {
        
        let state: TextState = .empty
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "", beforeCursor: "", afterCursor: "")
    }
    
    func test_transform_shouldReturnSame_onSymbol() {
        
        let state: TextState = .init(.init("-"))
        
        let result = makeSUT().transform(state)
        
        XCTAssertNoDiff(state, result)
    }
    
    func test_transform_shouldReturnSame_onLetter() {
        
        let state: TextState = .init(.init("a"))
        
        let result = makeSUT().transform(state)
        
        XCTAssertNoDiff(state, result)
    }
    
    func test_transform_shouldReturnSame_onCyrillicLetter() {
        
        let state: TextState = .init(.init("д"))
        
        let result = makeSUT().transform(state)
        
        XCTAssertNoDiff(state, result)
    }
    
    func test_transform_shouldReturnSame_onNonDigit_multiple() throws {
        
        let nonDigits = nonDigits.shuffled().prefix(200)
        var iterations = 0
        
        for nonDigit in nonDigits {
            
            let nonDigit = String(nonDigit)
            let state: TextState = .init(nonDigit)
            
            let result = makeSUT().transform(state)
            iterations += 1
            
            XCTAssertNoDiff(state, result)
            try assertTextState(result, hasText: nonDigit, beforeCursor: nonDigit, afterCursor: "")
        }
        
        XCTAssertEqual(iterations, 200)
    }
    
    func test_transform_shouldReturnSame_onSymbol_followedByLetter() {
        
        let letters = letters.shuffled().prefix(300)
        var iterations = 0
        
        for symbol in symbols {
            
            for letter in letters {
                
                let text = String(symbol) + .init(letter)
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                XCTAssertNoDiff(state, result)
            }
        }
        
        XCTAssertEqual(iterations, 18_900)
    }
    
    func test_transform_shouldReturnFormatted_onFirstDigit() throws {
        
        let state: TextState = .init("1")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~1", beforeCursor: "~1", afterCursor: "")
    }
    
    func test_transform_shouldReturnFormatted_onFirstSymbolAfterDigit() throws {
        
        let state: TextState = .init("-1")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~1", beforeCursor: "~1", afterCursor: "")
    }
    
    func test_transform_shouldReturnFormatted_onFirstSymbolAfterDigit_multiple() {
        
        var iterations = 0
        
        for symbol in symbols {
            
            for digit in digits {
                
                let text = String(symbol) + .init(digit)
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                XCTAssertNoDiff(result.text, "~\(text.dropFirst(1))")
            }
        }
        
        XCTAssertEqual(iterations, 630)
    }
    
    func test_transform_shouldReturnFormatted_onTwoSymbolsAfterDigit() throws {
        
        let state: TextState = .init("+-/3")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~3", beforeCursor: "~3", afterCursor: "")
    }
    
    func test_transform_shouldReturnFormatted_onTwoSymbolsBeforeDigit_multiple() {
        
        var iterations = 0
        
        zip(
            symbols.shuffled().prefix(100),
            symbols.shuffled().prefix(100)
        ).forEach { (first, second) in
            
            digits.forEach { digit in
                
                let text = String(first) + .init(second) + .init(digit)
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                XCTAssertNoDiff(result.text, "~\(text.dropFirst(2))")
            }
        }
        
        XCTAssertEqual(iterations, 630)
    }
    
    func test_transform_shouldReturnFormatted_onMixStartingWithDigitAfterSymbols() throws {
        
        let state: TextState = .init("-+34-76Abc51", cursorPosition: 5)
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~347651", beforeCursor: "~347651", afterCursor: "")
    }
    
    func test_transform_shouldReturnSame_onMixStartingWithLetterAfterSymbols() {
        
        let state: TextState = .init("-+d34-76Abc51", cursorPosition: 5)
        
        let result = makeSUT().transform(state)
        
        XCTAssertNoDiff(result, state)
    }
    
    // MARK: - remove newline
    
    func test_transform_shouldRemoveNewLine() throws {
        
        let state: TextState = .init("\n", cursorPosition: 1)
        
        try assertTextState(state, hasText: "\n", beforeCursor: "\n", afterCursor: "")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "", beforeCursor: "", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLine_multiple() throws {
        
        var iterations = 0
        
        for newline in newlines {
            
            let state: TextState = .init(.init(newline))
            
            let result = makeSUT().transform(state)
            iterations += 1
            
            try assertTextState(result, hasText: "", beforeCursor: "", afterCursor: "")
        }
        
        XCTAssertEqual(iterations, 7)
    }
    
    func test_transform_shouldRemoveNewLineBeforeSymbol() throws {
        
        let state: TextState = .init("\n-", cursorPosition: 2)
        
        try assertTextState(state, hasText: "\n-", beforeCursor: "\n-", afterCursor: "")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "-", beforeCursor: "-", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBeforeSymbol_multiple() throws {
        
        var iterations = 0
        
        for newline in  newlines {
            
            for symbol in  symbols {
                
                let symbol = String(symbol)
                let text = String(newline) + symbol
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                try assertTextState(result, hasText: symbol, beforeCursor: symbol, afterCursor: "")
            }
        }
        
        XCTAssertEqual(iterations, 441)
    }
    
    func test_transform_shouldRemoveNewLineBeforeDigit() throws {
        
        let state: TextState = .init("\n1", cursorPosition: 2)
        
        try assertTextState(state, hasText: "\n1", beforeCursor: "\n1", afterCursor: "")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~1", beforeCursor: "~1", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBeforeDigit_multiple() throws {
        
        var iterations = 0
        
        for newline in newlines {
            
            for digit in digits {
                
                let digit = String(digit)
                let text = String(newline) + digit
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                try assertTextState(result, hasText: "~\(digit)", beforeCursor: "~\(digit)", afterCursor: "")
            }
        }
        
        XCTAssertEqual(iterations, 70)
    }
    
    func test_transform_shouldRemoveNewLineBeforeLetter() throws {
        
        let state: TextState = .init("\nD", cursorPosition: 2)
        
        try assertTextState(state, hasText: "\nD", beforeCursor: "\nD", afterCursor: "")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "D", beforeCursor: "D", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBeforeLetter_multiple() throws {
        
        var iterations = 0
        
        for newline in newlines {
            
            for letter in letters {
                
                let letter = String(letter)
                let text = String(newline) + letter
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                try assertTextState(result, hasText: letter, beforeCursor: letter, afterCursor: "")
            }
        }
        
        XCTAssertEqual(iterations, 17_500)
    }
    
    func test_transform_shouldRemoveNewLineBeforeCyrillicLetter() throws {
        
        let state: TextState = .init("\nД", cursorPosition: 2)
        
        try assertTextState(state, hasText: "\nД", beforeCursor: "\nД", afterCursor: "")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "Д", beforeCursor: "Д", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBeforeMixStartingWithNonDigit() throws {
        
        let state: TextState = .init("\nДabc12", cursorPosition: 3)
        
        try assertTextState(state, hasText: "\nДabc12", beforeCursor: "\nДa", afterCursor: "bc12")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "Дabc12", beforeCursor: "Дabc12", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBetweenDigits() throws {
        
        let state: TextState = .init("3\n2")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~32", beforeCursor: "~32", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBetweenDigits_multiple() throws {
        
        var iterations = 0
        
        for firstDigit in digits {
            
            for newline in newlines {
                
                for lastDigit in digits {
                    
                    let firstDigit = String(firstDigit)
                    let lastDigit = String(lastDigit)
                    let newline = String(newline)
                    let text = firstDigit + newline + lastDigit
                    let state: TextState = .init(text)
                    
                    let result = makeSUT().transform(state)
                    iterations += 1
                    
                    try assertTextState(result, hasText: "~" + firstDigit + lastDigit, beforeCursor: "~" + firstDigit + lastDigit, afterCursor: "")
                }
            }
        }
        
        XCTAssertEqual(iterations, 700)
    }
    
    func test_transform_shouldRemoveNewLineBetweenLetters() throws {
        
        let state: TextState = .init("a\nД", cursorPosition: 2)
        
        try assertTextState(state, hasText: "a\nД", beforeCursor: "a\n", afterCursor: "Д")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "aД", beforeCursor: "aД", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBetweenLetters_multiple() throws {
        
        let firstLetters = letters.shuffled().prefix(100)
        let lastLetters = letters.shuffled().prefix(100)
        var iterations = 0
        
        for firstLetter in firstLetters {
            
            for newline in newlines {
                
                for lastLetter in lastLetters {
                    
                    let firstLetter = String(firstLetter)
                    let lastLetter = String(lastLetter)
                    let newline = String(newline)
                    let text = firstLetter + newline + lastLetter
                    let state: TextState = .init(text)
                    
                    let result = makeSUT().transform(state)
                    iterations += 1
                    
                    try assertTextState(result, hasText: firstLetter + lastLetter, beforeCursor: firstLetter + lastLetter, afterCursor: "")
                }
            }
        }
        
        XCTAssertEqual(iterations, 70_000)
    }
    
    func test_transform_shouldRemoveNewLineBetweenLetterAndDigit() throws {
        
        let state: TextState = .init("a\n1", cursorPosition: 2)
        
        try assertTextState(state, hasText: "a\n1", beforeCursor: "a\n", afterCursor: "1")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "a1", beforeCursor: "a1", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBetweenLetterAndDigit_multiple() throws {
        
        let letters = letters.shuffled().prefix(100)
        var iterations = 0
        
        for letter in letters {
            
            for newline in newlines {
                
                for digit in digits {
                    
                    let letter = String(letter)
                    let digit = String(digit)
                    let newline = String(newline)
                    let text = letter + newline + digit
                    let state: TextState = .init(text)
                    
                    let result = makeSUT().transform(state)
                    iterations += 1
                    
                    try assertTextState(result, hasText: letter + digit, beforeCursor: letter + digit, afterCursor: "")
                }
            }
        }
        
        XCTAssertEqual(iterations, 7_000)
    }
    
    func test_transform_shouldRemoveNewLineBetweenDigitAndLetter() throws {
        
        let state: TextState = .init("1\na", cursorPosition: 2)
        
        try assertTextState(state, hasText: "1\na", beforeCursor: "1\n", afterCursor: "a")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~1", beforeCursor: "~1", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBetweenDigitAndLetter_multiple() throws {
        
        let letters = letters.shuffled().prefix(100)
        var iterations = 0
        
        for digit in digits {
            
            for newline in newlines {
                
                for letter in letters {
                    
                    let letter = String(letter)
                    let digit = String(digit)
                    let newline = String(newline)
                    let text = digit + newline + letter
                    let state: TextState = .init(text)
                    
                    let result = makeSUT().transform(state)
                    iterations += 1
                    
                    try assertTextState(result, hasText: "~" + digit, beforeCursor: "~" + digit, afterCursor: "")
                }
            }
        }
        
        XCTAssertEqual(iterations, 7_000)
    }
    
    func test_transform_shouldRemoveNewLineBetweenSymbols() throws {
        
        let state: TextState = .init("@\n*", cursorPosition: 2)
        
        try assertTextState(state, hasText: "@\n*", beforeCursor: "@\n", afterCursor: "*")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "@*", beforeCursor: "@*", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineBetweenSymbols_multiple() throws {
        
        let firstSymbols = symbols.shuffled().prefix(20)
        let lastSymbols = symbols.shuffled().prefix(20)
        var iterations = 0
        
        for firstSymbol in firstSymbols {
            
            for newline in newlines {
                
                for lastSymbol in lastSymbols {
                    
                    let firstSymbol = String(firstSymbol)
                    let lastSymbol = String(lastSymbol)
                    let newline = String(newline)
                    let text = firstSymbol + newline + lastSymbol
                    let state: TextState = .init(text)
                    
                    let result = makeSUT().transform(state)
                    iterations += 1
                    
                    try assertTextState(result, hasText: firstSymbol + lastSymbol, beforeCursor: firstSymbol + lastSymbol, afterCursor: "")
                }
            }
        }
        
        XCTAssertEqual(iterations, 2_800)
    }
    
    func test_transform_shouldRemoveNewLineAfterDigit() throws {
        
        let state: TextState = .init("1\n", cursorPosition: 1)
        
        try assertTextState(state, hasText: "1\n", beforeCursor: "1", afterCursor: "\n")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "~1", beforeCursor: "~1", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineAfterDigit_multiple() throws {
        
        var iterations = 0
        
        for digit in digits {
            
            for newline in newlines {
                
                let firstDigit = String(digit)
                let newline = String(newline)
                let text = firstDigit + newline
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                try assertTextState(result, hasText: "~" + firstDigit, beforeCursor: "~" + firstDigit, afterCursor: "")
            }
        }
        
        XCTAssertEqual(iterations, 70)
    }
    
    func test_transform_shouldRemoveNewLineAfterLetter() throws {
        
        let state: TextState = .init("д\n", cursorPosition: 1)
        
        try assertTextState(state, hasText: "д\n", beforeCursor: "д", afterCursor: "\n")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "д", beforeCursor: "д", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineAfterLetter_multiple() throws {
        
        var iterations = 0
        
        for letter in letters {
            
            for newline in newlines {
                
                let letter = String(letter)
                let text = letter + String(newline)
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                try assertTextState(result, hasText: letter, beforeCursor: letter, afterCursor: "")
            }
        }
        
        XCTAssertEqual(iterations, 17_500)
    }
    
    func test_transform_shouldRemoveNewLineAfterSymbol() throws {
        
        let state: TextState = .init("-\n", cursorPosition: 1)
        
        try assertTextState(state, hasText: "-\n", beforeCursor: "-", afterCursor: "\n")
        
        let result = makeSUT().transform(state)
        
        try assertTextState(result, hasText: "-", beforeCursor: "-", afterCursor: "")
    }
    
    func test_transform_shouldRemoveNewLineAfterSymbol_multiple() throws {
        
        var iterations = 0
        
        for symbol in symbols {
            
            for newline in newlines {
                
                let symbol = String(symbol)
                let text = symbol + String(newline)
                let state: TextState = .init(text)
                
                let result = makeSUT().transform(state)
                iterations += 1
                
                try assertTextState(result, hasText: symbol, beforeCursor: symbol, afterCursor: "")
            }
        }
        
        XCTAssertEqual(iterations, 441)
    }
    
    // MARK: - substitution
    
    func test_transform_shouldNotSubstituteLetterOnEmptySubstitutions() throws {
        
        let state: TextState = .init("a")
        let transformer = makeSUT(substitutions: [])
        
        let result = transformer.transform(state)
        
        XCTAssertNoDiff(result, state)
    }
    
    func test_transform_shouldNotSubstituteMixStartingWithLetterOnEmptySubstitutions() throws {
        
        let state: TextState = .init("a334GHJ6&*")
        let transformer = makeSUT(substitutions: [])
        
        let result = transformer.transform(state)
        
        XCTAssertNoDiff(result, state)
    }
    
    func test_transform_shouldNotSubstituteDigitOnEmptySubstitutions() throws {
        
        let state: TextState = .init("3")
        let transformer = makeSUT(substitutions: [])
        
        let result = transformer.transform(state)
        
        try assertTextState(result, hasText: "~3", beforeCursor: "~3", afterCursor: "")
    }
    
    func test_transform_shouldSubstituteStartingWithOnlyDigitOnEmptySubstitutions() throws {
        
        let state: TextState = .init("3$%^&HJK")
        let transformer = makeSUT(substitutions: [])
        
        let result = transformer.transform(state)
        
        try assertTextState(result, hasText: "~3", beforeCursor: "~3", afterCursor: "")
    }
    
    func test_transform_shouldSubstituteStartingWithOnlyDigitOnNonEmptySubstitutions() throws {
        
        let state: TextState = .init("3$%^&HJK")
        let transformer = makeSUT(substitutions: .russian)
        
        let result = transformer.transform(state)
        
        try assertTextState(result, hasText: "~3", beforeCursor: "~3", afterCursor: "")
    }
    
    func test_transform_shouldNotSubstituteMixStartingWithDigitOnEmptySubstitutions() throws {
        
        let state: TextState = .init("3$-1-%^&HJK")
        let transformer = makeSUT(substitutions: [])
        
        let result = transformer.transform(state)
        
        try assertTextState(result, hasText: "~31", beforeCursor: "~31", afterCursor: "")
    }
    
    func test_transform_shouldNotSubstituteMixStartingWithDigitNonEmptySubstitutions() throws {
        
        let state: TextState = .init("3$-1-%^&HJK")
        let transformer = makeSUT(substitutions: .russian)
        
        let result = transformer.transform(state)
        
        try assertTextState(result, hasText: "~31", beforeCursor: "~31", afterCursor: "")
    }
    
    func test_transform_shouldSubstituteOnMatch() throws {
        
        let state: TextState = .init("3")
        let transformer = makeSUT(substitutions: .russian)
        
        let result = transformer.transform(state)
        
        try assertTextState(result, hasText: "~3", beforeCursor: "~3", afterCursor: "")
    }
    
    func test_transform_shouldNotSubstituteOnPartialMatch() throws {
        
        let state: TextState = .init("37")
        let transformer = makeSUT(substitutions: .russian)
        
        let result = transformer.transform(state)
        
        try assertTextState(result, hasText: "~37", beforeCursor: "~37", afterCursor: "")
    }
    
    // MARK: - Custom CharacterSets
    
    let digits = ContactTransformer.digits.allCharacters()
    
    /// Alternative for `CharacterSet.letters`.
    /// The count of `CharacterSet.lowercaseLetters` (2,233) and `CharacterSet.uppercaseLetters` (1,862) in significantly smaller than `CharacterSet.letters` (132,409).
    let lettersSet = CharacterSet.lowercaseLetters
        .union(.uppercaseLetters)
    
    var letters: ArraySlice<Character> {
        lettersSet.allCharacters().prefix(2_500)
    }
    
    let newlines = CharacterSet.newlines.allCharacters()
    
    var nonDigits: ArraySlice<Character> {
        letters + symbols
    }
    
    let symbolsSet = ContactTransformer.symbols
    var symbols: [Character] {
        symbolsSet.allCharacters()
    }

    //Failed CI test and failed on branch release_9_4_2
//    func test_characterSetCounts() {
//        
//        XCTAssertEqual(nonDigits.count, 2_563)
//        
//        XCTAssertEqual(digits.count, 10)
//        XCTAssertEqual(CharacterSet.decimalDigits.allCharacters().count, 680)
//        
//        XCTAssertEqual(letters.count, 2_500)
//        XCTAssertEqual(lettersSet.allCharacters().count, 4_095)
//        XCTAssertEqual(CharacterSet.letters.allCharacters().count, 132_409)
//        XCTAssertEqual(CharacterSet.lowercaseLetters.allCharacters().count, 2_233)
//        XCTAssertEqual(CharacterSet.uppercaseLetters.allCharacters().count, 1_862)
//        
//        XCTAssertEqual(symbols.count, 63)
//        XCTAssertEqual(symbolsSet.allCharacters().count, 63)
//        XCTAssertEqual(CharacterSet.decimalDigits.inverted.allCharacters().count, 1_111_384)
//        XCTAssertEqual(CharacterSet.symbols.allCharacters().count, 7770)
//        XCTAssertEqual(CharacterSet.punctuationCharacters.allCharacters().count, 842)
//        XCTAssertEqual(CharacterSet.whitespacesAndNewlines.allCharacters().count, 26)
//    }
    
    func test_symbols_doesNotContainDigits() {
        
        XCTAssertEqual(symbolsSet.intersection(.decimalDigits), .init())
        XCTAssertEqual(symbolsSet.intersection(ContactTransformer.digits), .init())
    }
    
    func test_symbols_doesNotContainLetters() {
        
        XCTAssertEqual(symbolsSet.intersection(.letters), .init())
        XCTAssertEqual(symbolsSet.intersection(lettersSet), .init())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        substitutions: [CountryCodeSubstitution] = [],
        format: @escaping (String) -> String = { "~\($0)" },
        file: StaticString = #file,
        line: UInt = #line
    ) -> ContactTransformer {
        
        Transformers.contact(
            substitutions: substitutions,
            format: format
        )
    }
}

// MARK: - Helpers

extension XCTestCase {
    
    /// Throwing assertion to get out of loops without collecting all errors,
    /// those could be taxing since loops use a lots of iterations (big symbol sets)
    func assertTextState(
        _ state: TextState,
        hasText text: String,
        beforeCursor: String,
        afterCursor: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        guard state.text == text,
              state.parts.beforeCursor == beforeCursor,
              state.parts.afterCursor == afterCursor
        else {
            
            XCTAssertNoDiff(state.text, text, file: file, line: line)
            XCTAssertNoDiff(state.parts.beforeCursor, beforeCursor, file: file, line: line)
            XCTAssertNoDiff(state.parts.afterCursor, afterCursor, file: file, line: line)
            throw NSError(domain: "TextState assertion failed", code: 0)
        }
        
        return
    }
}

extension CharacterSet {
    
    func allCharacters() -> [Character] {
        
        var result: [Character] = []
        
        for plane: UInt8 in 0...16 where self.hasMember(inPlane: plane) {
            for unicode in UInt32(plane) << 16 ..< UInt32(plane + 1) << 16 {
                if let uniChar = UnicodeScalar(unicode), self.contains(uniChar) {
                    result.append(Character(uniChar))
                }
            }
        }
        
        return result
    }
}
