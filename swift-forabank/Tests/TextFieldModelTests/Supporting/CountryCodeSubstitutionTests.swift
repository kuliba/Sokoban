//
//  CountryCodeSubstitutionTests.swift
//  
//
//  Created by Igor Malyarov on 16.05.2023.
//

import TextFieldModel
import XCTest

final class CountryCodeSubstitutionTests: XCTestCase {
    
    func test_match_shouldReturnNil_onMismatch() {
        
        let substitutions: [CountryCodeSubstitution] = [
            
            .init(from: "89", to: "+79"),
        ]
        
        XCTAssertEqual(substitutions.firstTo(matching: ""), nil)
        XCTAssertEqual(substitutions.firstTo(matching: " "), nil)
        XCTAssertEqual(substitutions.firstTo(matching: "0"), nil)
        XCTAssertEqual(substitutions.firstTo(matching: "  "), nil)
        XCTAssertEqual(substitutions.firstTo(matching: "12"), nil)
    }
    
    func test_match_shouldReturnTo_onMatch() {
        
        let substitutions: [CountryCodeSubstitution] = [
            
            .init(from: "89", to: "+7 9"),
        ]

        XCTAssertNil(substitutions.firstTo(matching: "3"))
        XCTAssertNil(substitutions.firstTo(matching: "8"))
        XCTAssertNil(substitutions.firstTo(matching: "9"))
        XCTAssertEqual(substitutions.firstTo(matching: "89"), "+7 9")
    }
}
