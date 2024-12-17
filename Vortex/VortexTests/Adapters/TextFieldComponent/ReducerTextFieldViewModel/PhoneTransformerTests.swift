//
//  PhoneTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

final class PhoneTransformerTests: XCTestCase {

    func test_shouldReturnEmpty_onEmpty() {
        
        let transformed = transform(.init(""))
        
        assertTextState(transformed, hasText: "", cursorAt: 0)
    }
    
    func test_shouldReturnSameNumbers_onNumbersOnly() {
        
        let transformed = transform(.init("9876543210"))
        
        assertTextState(transformed, hasText: "9876543210", cursorAt: 10)
    }
    
    func test_shouldReturnNumbers_onMix() {
        
        let transformed = transform(.init("a(9b87c-de6+54fg32)10k"))
        
        assertTextState(transformed, hasText: "9876543210", cursorAt: 10)
    }
    
    func test_shouldNotReplace_onPartialMatch() {
        
        let transformed = transform(
            .init("345-de6+54fg32)10k"),
            substitutions: [.init(from: "345", to: "00345")]
        )
        
        assertTextState(transformed, hasText: "3456543210", cursorAt: 10)
    }
    
    func test_shouldReplace_onWholeMatch() {
        
        let transformed = transform(
            .init("345"),
            substitutions: [.init(from: "345", to: "00345")]
        )
        
        assertTextState(transformed, hasText: "00345", cursorAt: 5)
    }
    
    func test_shouldNotReplace_onWholeMatchArmenian() {
        
        let transformed = transform(
            .init("3"),
            substitutions: .russian
        )
        
        assertTextState(transformed, hasText: "3", cursorAt: 1)
    }
    
    func test_shouldLimit_onLimit() {
    
        let transformed = transform(.init("0123456789"), limit: 5)
        
        assertTextState(transformed, hasText: "01234", cursorAt: 5)
    }
    
    func test_shouldNotLimit_onNilLimit() {
    
        let transformed = transform(
            .init("0123456789012345678901234567890123456789"),
            limit: nil
        )
        
        assertTextState(
            transformed,
            hasText: "0123456789012345678901234567890123456789",
            cursorAt: 40
        )
    }
    
    func test_shouldApplyFormatting() {
        
        let transformed = transform(
            .init("012345"),
            format: { $0.map({ "(\($0))" }).joined() }
        )
        
        assertTextState(transformed, hasText: "(0)(1)(2)(3)(4)(5)", cursorAt: 18)
    }
    
    func test_shouldReturnEmpty_onEmpty_integrated() {
        
        let transformed = transform(
            .init(""),
            substitutions: .test,
            limit: 11,
            format: { $0.map({ "\($0)_" }).joined()}
        )
        
        assertTextState(transformed, hasText: "", cursorAt: 0)
    }
    
    func test_shouldReplace_on3_integrated() {
        
        let transformed = transform(
            .init("3"),
            substitutions: .test,
            limit: 11,
            format: { "(\($0))" }
        )
        
        assertTextState(transformed, hasText: "(3)", cursorAt: 3)
    }
    
    // MARK: - Helpers
    
    private func transform(
        _ state: TextState,
        filterSymbols: [Character] = [],
        substitutions: [CountryCodeSubstitution] = [],
        limit: Int? = nil,
        format: @escaping (String) -> String = { $0 },
        file: StaticString = #file,
        line: UInt = #line
    ) -> TextState {
        
        let transformer = Transformers.phone(
            filterSymbols: filterSymbols,
            substitutions: substitutions,
            format: format,
            limit: limit
        )
        
        return transformer.transform(state)
    }
}
