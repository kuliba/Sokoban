//
//  CountryCodeSubstitutionTransformerTests.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

@testable import TextFieldDomain
@testable import TextFieldModel
import XCTest

final class CountryCodeSubstitutionTransformerTests: XCTestCase {
    
    func test_replace_shouldNotChangeState_onSubstitutionMismatch() {
        
        let transformer = Transformers.countryCodeSubstitute(.test)
        let state = TextState("a", cursorPosition: 0)
        
        let changed = transformer.transform(state)
        
        XCTAssertNoDiff(changed.view, .init("a", cursorAt: 0))
    }
    
    func test_replace_shouldNotChangeState_onSubstitutionMismatch2() {
        
        let transformer = Transformers.countryCodeSubstitute(.test)
        let state = TextState("a", cursorPosition: 1)
        
        let changed = transformer.transform(state)
        
        XCTAssertNoDiff(changed.view, .init("a", cursorAt: 1))
    }
    
    func test_replace_shouldChangeState_onSubstitutionMatch() {
        
        let transformer = Transformers.countryCodeSubstitute(.test)
        let state = TextState("3", cursorPosition: 1)
        
        let changed = transformer.transform(state)
        
        XCTAssertNoDiff(changed.view, .init("374", cursorAt: 3))
    }
    
    func test_replace_shouldChangeState_onSubstitutionMatch2() {
        
        let transformer = Transformers.countryCodeSubstitute(.test)
        let state = TextState("8", cursorPosition: 1)
        
        let changed = transformer.transform(state)
        
        XCTAssertNoDiff(changed.view, .init("7", cursorAt: 1))
    }
    
    func test_replace_shouldChangeState_onSubstitutionMatch3() {
        
        let transformer = Transformers.countryCodeSubstitute(.test)
        let state = TextState("9", cursorPosition: 1)
        
        let changed = transformer.transform(state)
        
        XCTAssertNoDiff(changed.view, .init("7 9", cursorAt: 3))
    }
    
    // MARK: - Simple tests for text
    
    func test_shouldReturnEmpty_onEmpty() {
        
        let transformed = makeSUT(source: "")
        
        XCTAssertNoDiff(transformed, .init(""))
    }
    
    func test_shouldReturnSame_onNoMatch() {
        
        let transformed = makeSUT(source: "abcde")
        
        XCTAssertNoDiff(transformed, .init("abcde"))
    }
    
    func test_shouldReplace_armenian_on3() {
        
        let transformed = makeSUT(source: "3", substitutions: .armenian)
        
        XCTAssertNoDiff(transformed, .init("374"))
    }
    
    func test_shouldNotReplace_armenian_on33() {
        
        let transformed = makeSUT(source: "33", substitutions: .armenian)
        
        XCTAssertNoDiff(transformed, .init("33"))
    }
    
    func test_shouldNotReplace_armenian_on372() {
        
        let transformed = makeSUT(source: "372", substitutions: .armenian)
        
        XCTAssertNoDiff(transformed, .init("372"))
    }
    
    func test_shouldReplace8To7_eightToSeven_on8() {
        
        let transformed = makeSUT(source: "8", substitutions: .russian)
        
        XCTAssertNoDiff(transformed, .init("7"))
    }
    
    func test_shouldNotReplace8To7_eightToSeven_on82() {
        
        let transformed = makeSUT(source: "82", substitutions: .russian)
        
        XCTAssertNoDiff(transformed, .init("82"))
    }
    
    func test_shouldNotReplace8To7_eightToSeven_on882() {
        
        let transformed = makeSUT(source: "882", substitutions: .russian)
        
        XCTAssertNoDiff(transformed, .init("882"))
    }
    
    func test_shouldReplace9ToPlus7_nineToPlusSeven_on9() {
        
        let transformed = makeSUT(source: "9", substitutions: .russian)
        
        XCTAssertNoDiff(transformed, .init("7 9"))
    }
    
    func test_shouldNotReplace9ToPlus7_nineToPlusSeven_on92() {
        
        let transformed = makeSUT(source: "92", substitutions: .russian)
        
        XCTAssertNoDiff(transformed, .init("92"))
    }
    
    func test_shouldNotReplace9ToPlus7_nineToPlusSeven_on922() {
        
        let transformed = makeSUT(source: "922", substitutions: .russian)
        
        XCTAssertNoDiff(transformed, .init("922"))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        source: String,
        substitutions: [CountryCodeSubstitution] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> TextState {
        
        return Transformers.countryCodeSubstitute(substitutions).transform(.init(source))
    }
    
}

extension Array where Element == CountryCodeSubstitution {
    
    static let test: Self = .armenian + .russian + .turkey
    
    static let armenian: Self = [
        .init(from: "8", to: "7"),
        .init(from: "3", to: "374"),
    ]
    
    static let russian: Self = [
        .init(from: "8", to: "7"),
        .init(from: "9", to: "7 9"),
    ]
    
    static let turkey: Self = [
        .init(from: "8", to: "7"),
        .init(from: "3", to: "374"),
        .init(from: "9", to: "90"),
    ]
}
