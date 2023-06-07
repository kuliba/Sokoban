//
//  ValidateTests.swift
//  
//
//  Created by Igor Malyarov on 20.05.2023.
//

import TextFieldModel
import XCTest

final class ValidateTests: XCTestCase {
    
    // MARK: - always
    
    func test_always_shouldReturnTrue_onEmpty() {
        
        let validator = Validate.always
        
        XCTAssertTrue(validator.isValid(""))
    }
    
    func test_always_shouldReturnTrue_onCharacter() {
        
        let validator = Validate.always
        
        XCTAssertTrue(validator.isValid("a"))
    }
    
    func test_always_shouldReturnTrue_onDigit() {
        
        let validator = Validate.always
        
        XCTAssertTrue(validator.isValid("7"))
    }
    
    func test_always_shouldReturnTrue_onText() {
        
        let validator = Validate.always
        
        XCTAssertTrue(validator.isValid("any text"))
    }
    
    func test_always_shouldReturnTrue_onNumber() {
        
        let validator = Validate.always
        
        XCTAssertTrue(validator.isValid("1234567890"))
    }
    
    // MARK: - never
    
    func test_never_shouldReturnFalse_onEmpty() {
        
        let validator = Validate.never
        
        XCTAssertFalse(validator.isValid(""))
    }
    
    func test_never_shouldReturnFalse_onCharacter() {
        
        let validator = Validate.never
        
        XCTAssertFalse(validator.isValid("a"))
    }
    
    func test_never_shouldReturnFalse_onDigit() {
        
        let validator = Validate.never
        
        XCTAssertFalse(validator.isValid("7"))
    }
    
    func test_never_shouldReturnFalse_onText() {
        
        let validator = Validate.never
        
        XCTAssertFalse(validator.isValid("any text"))
    }
    
    func test_never_shouldReturnFalse_onNumber() {
        
        let validator = Validate.never
        
        XCTAssertFalse(validator.isValid("1234567890"))
    }
    
    // MARK: - digits
    
    func test_digits_shouldReturnTrue_onEmpty() {
        
        let validator = Validate.digits
        
        XCTAssertTrue(validator.isValid(""))
    }
    
    func test_digits_shouldReturnFalse_onCharacter() {
        
        let validator = Validate.digits
        
        XCTAssertFalse(validator.isValid("a"))
    }
    
    func test_digits_shouldReturnTrue_onDigit() {
        
        let validator = Validate.digits
        
        XCTAssertTrue(validator.isValid("7"))
    }
    
    func test_digits_shouldReturnFalse_onText() {
        
        let validator = Validate.digits
        
        XCTAssertFalse(validator.isValid("any text"))
    }
    
    func test_digits_shouldReturnTrue_onNumber() {
        
        let validator = Validate.digits
        
        XCTAssertTrue(validator.isValid("1234567890"))
    }
    
    // MARK: - letters
    
    func test_letters_shouldReturnTrue_onEmpty() {
        
        let validator = Validate.letters
        
        XCTAssertTrue(validator.isValid(""))
    }
    
    func test_letters_shouldReturnTrue_onCharacter() {
        
        let validator = Validate.letters
        
        XCTAssertTrue(validator.isValid("a"))
    }
    
    func test_letters_shouldReturnFalse_onDigit() {
        
        let validator = Validate.letters
        
        XCTAssertFalse(validator.isValid("7"))
    }
    
    func test_letters_shouldReturnTrue_onText() {
        
        let validator = Validate.letters
        
        XCTAssertTrue(validator.isValid("anyText"))
    }
    
    func test_letters_shouldReturnFalse_onTextWithSpace() {
        
        let validator = Validate.letters
        
        XCTAssertFalse(validator.isValid("any text"))
    }
    
    func test_letters_shouldReturnFalse_onNumber() {
        
        let validator = Validate.letters
        
        XCTAssertFalse(validator.isValid("1234567890"))
    }
}
