//
//  ContactReducerTests.swift
//  
//
//  Created by Igor Malyarov on 26.05.2023.
//

import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class ContactReducerTests: XCTestCase {
    
    func test_reduce_shouldThrowOnPasteInPlaceholderState() {
        
        let sut = makeSUT().sut
        
        XCTAssertThrowsError(
            _ = try sut.reduce(
                .placeholder("A placeholder"),
                actions: { try $0.paste("12345") }
            )
        ) {
            XCTAssertNoDiff($0 as NSError, NSError(domain: "Expected `editing` state, got placeholder(\"A placeholder\")", code: 0))
        }
    }
    
    func test_reduce_shouldThrowOnPasteInNoFocusState() {
        
        let sut = makeSUT().sut
        
        XCTAssertThrowsError(
            _ = try sut.reduce(
                .noFocus("+2"),
                actions: { try $0.paste("12345") }
            )
        ) {
            XCTAssertNoDiff($0 as NSError, NSError(domain: "Expected `editing` state, got noFocus(\"+2\")", code: 0))
        }
    }
    
    func test_reduce_seriesOfActions_withSubstitutions() throws {
        
        let (state, sut) = makeSUT(substitutions: .russian)
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("3") },
            { try $0.insert("456789") },
            { try $0.paste("8") },
            { try $0.insert("3") },
            { try $0.insert("123456") },
            { try $0.paste("9") },
            { try $0.paste("8916") },
            { try $0.paste("Abc def 123") },
            { try $0.paste("+-Abc 123") },
            { try $0.paste("+-#8916") },
            { _ in .finishEditing },
            { _ in .startEditing },
            { try $0.paste("") },
            { _ in .finishEditing }
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter contact name or phone"),
            .editing(.empty),
            .editing(.init("~3",        cursorAt: 2)),
            .editing(.init("~3456789",  cursorAt: 8)),
            .editing(.init("~8",          cursorAt: 2)),
            .editing(.init("~83",         cursorAt: 3)),
            .editing(.init("~83123456",   cursorAt: 9)),
            .editing(.init("~9",        cursorAt: 2)),
            .editing(.init("~8916",       cursorAt: 5)),
            .editing(.init("Abc def 123", cursorAt: 11)),
            .editing(.init("+-Abc 123",   cursorAt: 9)),
            .editing(.init("~8916",       cursorAt: 5)),
            .noFocus("~8916"),
            .editing(.init("~8916",       cursorAt: 5)),
            .editing(.init("",            cursorAt: 5)),
            .placeholder("Enter contact name or phone"),
        ])
    }
    
    func test_reduce_nonDigitInputShouldBeIgnoredIfFirstNonSymbolIsDigit_akaPhoneMode_paste() throws {
        
        let (state, sut) = makeSUT(substitutions: .russian)
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("$") },
            { try $0.paste("-") },
            { try $0.paste("3") },
            { try $0.insert("Abc456 78") },
            { try $0.insert("9cdf") },
            { try $0.replace(from: 2, count: 6, with: "EF-&G1")}
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter contact name or phone"),
            .editing(.empty),
            .editing(.init("$",          cursorAt: 1)),
            .editing(.init("-",          cursorAt: 1)),
            .editing(.init("~3",       cursorAt: 2)),
            .editing(.init("~345678",  cursorAt: 7)),
            .editing(.init("~3456789", cursorAt: 8)),
            .editing(.init("~31",       cursorAt: 3)),
        ])
    }
    
    func test_reduce_nonDigitInputShouldBeIgnoredIfFirstNonSymbolIsDigit_akaPhoneMode_insert() throws {
        
        let (state, sut) = makeSUT(substitutions: .russian)
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("$") },
            { try $0.insert("-") },
            { try $0.insert("3") },
            { try $0.insert("Abc456 78") },
            { try $0.insert("9cdf") },
            { try $0.replace(from: 2, count: 6, with: "EF-&G1")}
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter contact name or phone"),
            .editing(.empty),
            .editing(.init("$",          cursorAt: 1)),
            .editing(.init("$-",         cursorAt: 2)),
            .editing(.init("~3",       cursorAt: 2)),
            .editing(.init("~345678",  cursorAt: 7)),
            .editing(.init("~3456789", cursorAt: 8)),
            .editing(.init("~31",       cursorAt: 3)),
        ])
    }
    
    func test_reduce_anyInputShouldBeAddedIfFirstNonSymbolIsLetter_akaNameMode_paste() throws {
        
        let (state, sut) = makeSUT(substitutions: .russian)
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("$") },
            { try $0.paste("-") },
            { try $0.paste("д") },
            { try $0.insert("Abc456 78") },
            { try $0.insert("9cdf") },
            { try $0.replace(from: 2, count: 7, with: "EF-&G1")}
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter contact name or phone"),
            .editing(.empty),
            .editing(.init("$",              cursorAt: 1)),
            .editing(.init("-",              cursorAt: 1)),
            .editing(.init("д",              cursorAt: 4)),
            .editing(.init("дAbc456 78",     cursorAt: 10)),
            .editing(.init("дAbc456 789cdf", cursorAt: 14)),
            .editing(.init("дAEF-&G189cdf",  cursorAt: 8)),
        ])
    }
    
    func test_reduce_anyInputShouldBeAddedIfFirstNonSymbolIsLetter_akaNameMode_insert() throws {
        
        let (state, sut) = makeSUT(substitutions: .russian)
        
        let result = try sut.reduce(
            state,
            actions: { _ in .startEditing },
            { try $0.insert("$") },
            { try $0.insert("-") },
            { try $0.insert("д") },
            { try $0.insert("Abc456 78") },
            { try $0.insert("9cdf") },
            { try $0.replace(from: 2, count: 7, with: "EF-&G1")}
        )
        
        XCTAssertNoDiff(result, [
            .placeholder("Enter contact name or phone"),
            .editing(.empty),
            .editing(.init("$",                cursorAt: 1)),
            .editing(.init("$-",               cursorAt: 2)),
            .editing(.init("$-д",              cursorAt: 3)),
            .editing(.init("$-дAbc456 78",     cursorAt: 12)),
            .editing(.init("$-дAbc456 789cdf", cursorAt: 16)),
            .editing(.init("$-EF-&G1 789cdf",  cursorAt: 8)),
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        placeholderText: String = "Enter contact name or phone",
        substitutions: [CountryCodeSubstitution] = [],
        format: @escaping (String) -> String = { "~\($0)" },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        state: TextFieldState,
        sut: TransformingReducer
    ) {
        let state: TextFieldState = .init(placeholderText)
        
        let reducer = TransformingReducer.contact(
            placeholderText: placeholderText,
            substitutions: substitutions,
            format: format
        )
        
        return (state, reducer)
    }
}
