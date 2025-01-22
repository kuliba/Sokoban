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
    
    // MARK: - checkbox: not required
    
    func test_checkbox_notRequired_shouldNotDeliverErrorOnNilValue() {
        
        assert(value: nil, type: .checkbox, isRequired: false, validationError: nil)
    }
    
    func test_checkbox_notRequired_shouldNotDeliverErrorOnEmptyValue() {
        
        assert(value: "", type: .checkbox, isRequired: false, validationError: nil)
    }
    
    func test_checkbox_notRequired_shouldNotDeliverErrorOnZeroValue() {
        
        assert(value: "0", type: .checkbox, isRequired: false, validationError: nil)
    }
    
    func test_checkbox_notRequired_shouldNotDeliverErrorOnOneValue() {
        
        assert(value: "1", type: .checkbox, isRequired: false, validationError: nil)
    }
    
    func test_checkbox_notRequired_shouldNotDeliverErrorOnTextValue() {
        
        assert(value: "abc", type: .checkbox, isRequired: false, validationError: .invalidCheckbox)
    }
    
    // MARK: - checkbox: not required
    
    func test_checkbox_required_shouldDeliverErrorOnNilValue() {
        
        assert(value: nil, type: .checkbox, isRequired: true, validationError: .invalidCheckbox)
    }
    
    func test_checkbox_required_shouldNotDeliverErrorOnEmptyValue() {
        
        assert(value: "", type: .checkbox, isRequired: true, validationError: .invalidCheckbox)
    }
    
    func test_checkbox_required_shouldDeliverErrorOnZeroValue() {
        
        assert(value: "0", type: .checkbox, isRequired: true, validationError: .invalidCheckbox)
    }
    
    func test_checkbox_required_shouldNotDeliverErrorOnOneValue() {
        
        assert(value: "1", type: .checkbox, isRequired: true, validationError: nil)
    }
    
    func test_checkbox_required_shouldDeliverErrorOnTextValue() {
        
        assert(value: "abc", type: .checkbox, isRequired: true, validationError: .invalidCheckbox)
    }
    
    // MARK: - not required
    
    func test_notRequired_shouldNotDeliverErrorOnNilValue() {
        
        assert(value: nil, isRequired: false, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnEmptyValue() {
        
        assert(value: "", isRequired: false, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNonEmptyValue() {
        
        assert(isRequired: false, validationError: nil)
    }
    
    // MARK: - required
    
    func test_required_shouldDeliverErrorOnNilValue() {
        
        assert(value: nil, isRequired: true, validationError: .emptyRequired)
    }
    
    func test_required_shouldDeliverErrorOnEmptyValue() {
        
        assert(value: "", isRequired: true, validationError: .emptyRequired)
    }
    
    func test_required_shouldNotDeliverErrorOnNonEmptyValue() {
        
        assert(isRequired: true, validationError: nil)
    }
    
    // MARK: - not required: min length
    
    func test_notRequired_shouldNotDeliverErrorOnNilValueOnEmptyMinLength() {
        
        assert(value: .none, isRequired: false, minLength: nil, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnEmptyValueOnEmptyMinLength() {
        
        assert(value: "", isRequired: false, minLength: nil, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMinLength() {
        
        assert(value: "abc", isRequired: false, minLength: nil, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNilValueOnZeroMinLength() {
        
        assert(value: .none, isRequired: false, minLength: 0, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnEmptyValueOnZeroMinLength() {
        
        assert(value: "", isRequired: false, minLength: 0, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNonEmptyValueOnZeroMinLength() {
        
        assert(value: "abc", isRequired: false, minLength: 0, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNilValueOnMinLength() {
        
        assert(value: .none, isRequired: false, minLength: 1, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnEmptyValueOnMinLength() {
        
        assert(value: "", isRequired: false, minLength: 1, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnSameLengthValueOnMinLength() {
        
        assert(value: "a", isRequired: false, minLength: 1, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnLongerValueOnMinLength() {
        
        assert(value: "abc", isRequired: false, minLength: 1, validationError: nil)
    }
    
    // MARK: - required: min length
    
    func test_required_shouldDeliverErrorOnNilValueOnEmptyMinLength() {
        
        assert(value: .none, isRequired: true, minLength: nil, validationError: .emptyRequired)
    }
    
    func test_required_shouldNotDeliverErrorOnEmptyValueOnEmptyMinLength() {
        
        assert(value: "", isRequired: true, minLength: nil, validationError: .emptyRequired)
    }
    
    func test_required_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMinLength() {
        
        assert(value: "abc", isRequired: true, minLength: nil, validationError: nil)
    }
    
    func test_required_shouldDeliverErrorOnNilValueOnZeroMinLength() {
        
        assert(value: .none, isRequired: true, minLength: 0, validationError: .emptyRequired)
    }
    
    func test_required_shouldDeliverErrorOnEmptyValueOnZeroMinLength() {
        
        assert(value: "", isRequired: true, minLength: 0, validationError: .emptyRequired)
    }
    
    func test_required_shouldNotDeliverErrorOnNonEmptyValueOnZeroMinLength() {
        
        assert(value: "abc", isRequired: true, minLength: 0, validationError: nil)
    }
    
    func test_required_shouldDeliverErrorOnNilValueOnMinLength() {
        
        assert(value: .none, isRequired: true, minLength: 1, validationError: .emptyRequired)
    }
    
    func test_required_shouldDeliverErrorOnEmptyValueOnMinLength() {
        
        assert(value: "", isRequired: true, minLength: 1, validationError: .emptyRequired)
    }
    
    func test_required_shouldNotDeliverErrorOnSameLengthValueOnMinLength() {
        
        assert(value: "a", isRequired: true, minLength: 1, validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorOnLongerValueOnMinLength() {
        
        assert(value: "abc", isRequired: true, minLength: 1, validationError: nil)
    }
    
    // MARK: - not required: max length
    
    func test_notRequired_shouldNotDeliverErrorOnNilValueOnEmptyMaxLength() {
        
        assert(value: .none, isRequired: false, maxLength: nil, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnEmptyValueOnEmptyMaxLength() {
        
        assert(value: "", isRequired: false, maxLength: nil, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMaxLength() {
        
        assert(value: "abc", isRequired: false, maxLength: nil, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNilValueOnZeroMaxLength() {
        
        assert(value: .none, isRequired: false, maxLength: 0, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnEmptyValueOnZeroMaxLength() {
        
        assert(value: "", isRequired: false, maxLength: 0, validationError: nil)
    }
    
    func test_notRequired_shouldDeliverErrorOnNonEmptyValueOnZeroMaxLength() {
        
        assert(value: "abc", isRequired: false, maxLength: 0, validationError: .tooLong)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnNilValueOnMaxLength() {
        
        assert(value: .none, isRequired: false, maxLength: 1, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnEmptyValueOnMaxLength() {
        
        assert(value: "", isRequired: false, maxLength: 1, validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorOnSameLengthValueOnMaxLength() {
        
        assert(value: "a", isRequired: false, maxLength: 1, validationError: nil)
    }
    
    func test_notRequired_shouldDeliverErrorOnLongerValueOnMaxLength() {
        
        assert(value: "abc", isRequired: false, maxLength: 1, validationError: .tooLong)
    }
    
    // MARK: - required: max length
    
    func test_required_shouldNotDeliverErrorOnNilValueOnEmptyMaxLength() {
        
        assert(value: .none, isRequired: false, maxLength: nil, validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorOnEmptyValueOnEmptyMaxLength() {
        
        assert(value: "", isRequired: false, maxLength: nil, validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMaxLength() {
        
        assert(value: "abc", isRequired: false, maxLength: nil, validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorOnNilValueOnZeroMaxLength() {
        
        assert(value: .none, isRequired: false, maxLength: 0, validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorOnEmptyValueOnZeroMaxLength() {
        
        assert(value: "", isRequired: false, maxLength: 0, validationError: nil)
    }
    
    func test_required_shouldDeliverErrorOnNonEmptyValueOnZeroMaxLength() {
        
        assert(value: "abc", isRequired: false, maxLength: 0, validationError: .tooLong)
    }
    
    func test_required_shouldNotDeliverErrorOnNilValueOnMaxLength() {
        
        assert(value: .none, isRequired: false, maxLength: 1, validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorOnEmptyValueOnMaxLength() {
        
        assert(value: "", isRequired: false, maxLength: 1, validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorOnSameLengthValueOnMaxLength() {
        
        assert(value: "a", isRequired: false, maxLength: 1, validationError: nil)
    }
    
    func test_required_shouldDeliverErrorOnLongerValueOnMaxLength() {
        
        assert(value: "abc", isRequired: false, maxLength: 1, validationError: .tooLong)
    }
    
    // MARK: - not required: regExp
    
    func test_notRequired_shouldNotDeliverErrorForNilValueOnEmptyRegex() {
        
        assert(value: nil, isRequired: false, regExp: "", validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorForEmptyValueOnEmptyRegex() {
        
        assert(value: "", isRequired: false, regExp: "", validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorForNonEmptyValueOnEmptyRegex() {
        
        assert(value: "abc", isRequired: false, regExp: "", validationError: nil)
    }
    
    func test_notRequired_shouldNotDeliverErrorForMatchingRegex() {
        
        assert(value: "abc123", isRequired: false, regExp: "^[a-zA-Z0-9]+$", validationError: nil)
    }
    
    func test_notRequired_shouldDeliverErrorForNonMatchingRegex() {
        
        assert(value: "abc-123", isRequired: false, regExp: "^[a-zA-Z0-9]+$", validationError: .regExViolation)
    }
    
    func test_notRequired_withRealLifeRegEx() {
        
        // A number with 1 to 30 digits followed by a period and 1 to 4 digits.
        // A whole number with 1 to 30 digits.
        // A number with 1 to 30 digits followed by a comma and 1 to 4 digits.
        // A single space character.
        let pattern = "^((\\d{1,30}\\.\\d{1,4})|(\\d{1,30})|(\\d{1,30},\\d{1,4})|([ ]{1}))$"
        
        assert(value: "", isRequired: false, regExp: pattern, validationError: nil)
        
        assert(value: "12.34", isRequired: false, regExp: pattern, validationError: nil)
        assert(value: "12.34567", isRequired: false, regExp: pattern, validationError: .regExViolation)
        assert(value: "1234", isRequired: false, regExp: pattern, validationError: nil)
        assert(value: "12,34", isRequired: false, regExp: pattern, validationError: nil)
        assert(value: "12,34567", isRequired: false, regExp: pattern, validationError: .regExViolation)
        assert(value: " ", isRequired: false, regExp: pattern, validationError: nil)
    }
    
    // MARK: - required: regExp
    
    func test_required_shouldDeliverErrorForNilValueOnEmptyRegex() {
        
        assert(value: nil, isRequired: true, regExp: "", validationError: .emptyRequired)
    }
    
    func test_required_shouldDeliverErrorForEmptyValueOnEmptyRegex() {
        
        assert(value: "", isRequired: true, regExp: "", validationError: .emptyRequired)
    }
    
    func test_required_shouldNotDeliverErrorForNonEmptyValueOnEmptyRegex() {
        
        assert(value: "abc", isRequired: true, regExp: "", validationError: nil)
    }
    
    func test_required_shouldNotDeliverErrorForMatchingRegex() {
        
        assert(value: "abc123", isRequired: true, regExp: "^[a-zA-Z0-9]+$", validationError: nil)
    }
    
    func test_required_shouldDeliverErrorForNonMatchingRegex() {
        
        assert(value: "abc-123", isRequired: true, regExp: "^[a-zA-Z0-9]+$", validationError: .regExViolation)
    }
    
    func test_required_withRealLifeRegEx() {
        
        // A number with 1 to 30 digits followed by a period and 1 to 4 digits.
        // A whole number with 1 to 30 digits.
        // A number with 1 to 30 digits followed by a comma and 1 to 4 digits.
        // A single space character.
        let pattern = "^((\\d{1,30}\\.\\d{1,4})|(\\d{1,30})|(\\d{1,30},\\d{1,4})|([ ]{1}))$"
        
        assert(value: "", isRequired: true, regExp: pattern, validationError: .emptyRequired)
        
        assert(value: "12.34", isRequired: true, regExp: pattern, validationError: nil)
        assert(value: "12.34567", isRequired: true, regExp: pattern, validationError: .regExViolation)
        assert(value: "1234", isRequired: true, regExp: pattern, validationError: nil)
        assert(value: "12,34", isRequired: true, regExp: pattern, validationError: nil)
        assert(value: "12,34567", isRequired: true, regExp: pattern, validationError: .regExViolation)
        assert(value: " ", isRequired: true, regExp: pattern, validationError: nil)
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
        type: AnywayElement.Parameter.UIAttributes.FieldType = .input,
        isRequired: Bool,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, type: type, isRequired: isRequired),
                file: file, line: line
            ),
            validationError,
            file: file, line: line
        )
    }
    
    private func assert(
        value: String?,
        type: AnywayElement.Parameter.UIAttributes.FieldType = .input,
        isRequired: Bool,
        maxLength: Int?,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, type: type, isRequired: isRequired, maxLength: maxLength),
                file: file, line: line
            ),
            validationError,
            file: file, line: line
        )
    }
    
    private func assert(
        value: String?,
        isRequired: Bool,
        minLength: Int?,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, isRequired: isRequired, minLength: minLength),
                file: file, line: line
            ),
            validationError,
            file: file, line: line
        )
    }
    
    private func assert(
        value: String?,
        isRequired: Bool,
        regExp pattern: String,
        validationError: AnywayPaymentParameterValidationError?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            validate(
                makeAnywayPaymentParameter(value: value, isRequired: isRequired, regExp: pattern),
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
