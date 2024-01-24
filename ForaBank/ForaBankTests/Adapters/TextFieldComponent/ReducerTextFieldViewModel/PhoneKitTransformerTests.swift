//
//  PhoneKitTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

// TODO: добавить тесты!!!

final class PhoneKitTransformerTests: XCTestCase {

    func test_shouldReturnEmpty_onEmpty() {
        
        let transformed = transform(.init(""))
        
        assertTextState(transformed, hasText: "", cursorAt: 0)
    }
    
    func test_shouldReturnArmenianCode_on3() {
        
        let transformed = transform(.init("3"))
        
        assertTextState(transformed, hasText: "+3", cursorAt: 2)
    }
    
    func test_shouldReturnRuCode_on89() {
        
        let transformed = transform(.init("89"))
        
        assertTextState(transformed, hasText: "+7 9", cursorAt: 4)
    }
    
    /*func test_shouldReturnRuCodeWith9_on9() {
        
        let transformed = transform(.init("9"))
        
        assertTextState(transformed, hasText: "+7 9", cursorAt: 4)
    }*/
    
    func test_shouldReturnEmpty_onNonDigits() {
        
        let transformed = transform(.init("abcd"))
        
        assertTextState(transformed, hasText: "", cursorAt: 0)
    }
    
    func test_shouldReturnPartiallyFormatted_on3WithNonDigits() {
        
        let transformed = transform(.init("$%^3fghj"))
        
        assertTextState(transformed, hasText: "+3", cursorAt: 2)
    }
    
    func test_shouldReturnFormattedPartialPhoneNumber() {
        
        let transformed = transform(.init("123456789"))
        
        assertTextState(transformed, hasText: "+1 234-567-89", cursorAt: 13)
    }
    
    func test_shouldReturnFormattedPartialPhoneNumber_() {
        
        let transformed = transform(.init("12a3456--789"))
        
        assertTextState(transformed, hasText: "+1 234-567-89", cursorAt: 13)
    }
    
    func test_shouldReturnFormattedPhoneNumber() {
        
        let transformed = transform(.init("79123456789"))
        
        assertTextState(transformed, hasText: "+7 912 345-67-89", cursorAt: 16)
    }
    
    func test_shouldReturnFormattedPhoneNumber_() {
        
        let transformed = transform(.init("7-(912)34-56-789"))
        
        assertTextState(transformed, hasText: "+7 912 345-67-89", cursorAt: 16)
    }
    
    // MARK: - Helpers
    
    private func transform(
        _ state: TextState,
        file: StaticString = #file,
        line: UInt = #line
    ) -> TextState {
        
        return Transformers
            .phoneKit(filterSymbols: [], substitutions: [])
            .transform(state)
    }
}

extension Array where Element == CountryCodeReplace {
    
    static let test: Self = .russian
}

extension Array where Element == CountryCodeSubstitution {
    
    static let test: Self = .russian
    
    static let russian: Self = [
        .init(from: "89", to: "79"),
    ]
}
