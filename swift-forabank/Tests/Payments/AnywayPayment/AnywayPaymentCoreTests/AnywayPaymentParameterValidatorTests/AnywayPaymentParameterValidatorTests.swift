//
//  AnywayPaymentParameterValidatorTests.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentParameterValidatorTests: XCTestCase {
    
    // MARK: - required
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOfNonRequiredParameter() {
        
        assert(value: nil, isRequired: false, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOfNonRequiredParameter() {
        
        assert(isRequired: false, validationError: nil)
    }
    
    func test_isValid_shouldDeliverErrorOnEmptyValueOfRequiredParameter() {
        
        assert(value: nil, isRequired: true, validationError: .emptyRequired)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOfRequiredParameter() {
        
        assert(isRequired: true, validationError: nil)
    }
    
    // MARK: - min length
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnEmptyMinLength() {
        
        assert(value: .none, minLength: nil, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnEmptyMinLength() {
        
        assert(value: "", minLength: nil, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMinLength() {
        
        assert(value: "abc", minLength: nil, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnZeroMinLength() {
        
        assert(value: .none, minLength: 0, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnZeroMinLength() {
        
        assert(value: "", minLength: 0, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOnZeroMinLength() {
        
        assert(value: "abc", minLength: 0, validationError: nil)
    }
    
    func test_isValid_shouldDeliverErrorOnNilValueOnMinLength() {
        
        assert(value: .none, minLength: 1, validationError: .tooShort)
    }
    
    func test_isValid_shouldDeliverErrorOnEmptyValueOnMinLength() {
        
        assert(value: "", minLength: 1, validationError: .tooShort)
    }
    
    func test_isValid_shouldNotDeliverErrorOnSameLengthValueOnMinLength() {
        
        assert(value: "a", minLength: 1, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnLongerValueOnMinLength() {
        
        assert(value: "abc", minLength: 1, validationError: nil)
    }
    
    // MARK: - min length
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnEmptyMaxLength() {
        
        assert(value: .none, maxLength: nil, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnEmptyMaxLength() {
        
        assert(value: "", maxLength: nil, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMaxLength() {
        
        assert(value: "abc", maxLength: nil, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnZeroMaxLength() {
        
        assert(value: .none, maxLength: 0, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnZeroMaxLength() {
        
        assert(value: "", maxLength: 0, validationError: nil)
    }
    
    func test_isValid_shouldDeliverErrorOnNonEmptyValueOnZeroMaxLength() {
        
        assert(value: "abc", maxLength: 0, validationError: .tooLong)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnMaxLength() {
        
        assert(value: .none, maxLength: 1, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnMaxLength() {
        
        assert(value: "", maxLength: 1, validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorOnSameLengthValueOnMaxLength() {
        
        assert(value: "a", maxLength: 1, validationError: nil)
    }
    
    func test_isValid_shouldDeliverErrorOnLongerValueOnMaxLength() {
        
        assert(value: "abc", maxLength: 1, validationError: .tooLong)
    }
    
    // MARK: - regExp
    
    func test_isValid_shouldNotDeliverErrorForNilValueOnEmptyRegex() {
        
        assert(value: nil, regExp: "", validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorForEmptyValueOnEmptyRegex() {
        
        assert(value: "", regExp: "", validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorForNonEmptyValueOnEmptyRegex() {
        
        assert(value: "abc", regExp: "", validationError: nil)
    }
    
    func test_isValid_shouldNotDeliverErrorForMatchingRegex() {
        
        assert(value: "abc123", regExp: "^[a-zA-Z0-9]+$", validationError: nil)
    }
    
    func test_isValid_shouldDeliverErrorForNonMatchingRegex() {
        
        assert(value: "abc-123", regExp: "^[a-zA-Z0-9]+$", validationError: .regExViolation)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentParameterValidator
    private typealias Parameter = AnywayElement.Parameter
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assert(
        value: String? = anyMessage(),
        isRequired: Bool,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, isRequired: isRequired),
                file: file, line: line
            ),
            validationError,
            file: file, line: line
        )
    }
    
    private func assert(
        value: String?,
        maxLength: Int?,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, maxLength: maxLength),
                file: file, line: line
            ),
            validationError,
            file: file, line: line
        )
    }
    
    private func assert(
        value: String?,
        minLength: Int?,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, minLength: minLength),
                file: file, line: line
            ),
            validationError,
            file: file, line: line
        )
    }
    
    private func assert(
        value: String?,
        regExp pattern: String,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, regExp: pattern),
                file: file, line: line
            ),
            validationError,
            file: file, line: line
        )
    }
    
    private func validate(
        _ parameter: Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AnywayPaymentParameterValidationError? {
        
        let sut = makeSUT(file: file, line: line)
        
        return sut.validate(parameter)
    }
}
