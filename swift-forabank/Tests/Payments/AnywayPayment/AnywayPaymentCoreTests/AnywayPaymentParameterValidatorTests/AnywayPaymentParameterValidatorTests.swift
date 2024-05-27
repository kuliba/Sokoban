//
//  AnywayPaymentParameterValidatorTests.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentDomain

final class AnywayPaymentParameterValidator {}

extension AnywayPaymentParameterValidator {
    
    func isValid(_ parameter: Parameter) -> Bool {
        
        guard isRequiredValid(parameter),
              isMinLengthValid(parameter),
              isMaxLengthValid(parameter),
              isRegExpValid(parameter)
        else { return false }
        
        return true
    }
}

extension AnywayPaymentParameterValidator {
    
    typealias Parameter = AnywayPayment.Element.Parameter
}

private extension AnywayPaymentParameterValidator {
    
    func isRequiredValid(_ parameter: Parameter) -> Bool {
        
        parameter.validation.isRequired
        ? parameter.field.value != nil
        : true
    }
    
    func isMinLengthValid(_ parameter: Parameter) -> Bool {
        
        guard let minLength = parameter.validation.minLength else { return true }
        
        let value = parameter.field.value?.rawValue ?? ""
        
        return value.count >= minLength
    }
    
    func isMaxLengthValid(_ parameter: Parameter) -> Bool {
        
        guard let maxLength = parameter.validation.maxLength else { return true }
        
        let value = parameter.field.value?.rawValue ?? ""
        
        return value.count <= maxLength
    }
    
    func isRegExpValid(_ parameter: Parameter) -> Bool {
        
        guard !parameter.validation.regExp.isEmpty else { return true }
        
        let value = parameter.field.value?.rawValue ?? ""
        let pattern = parameter.validation.regExp
        
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}

import XCTest

final class AnywayPaymentParameterValidatorTests: XCTestCase {
    
    // MARK: - required
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOfNonRequiredParameter() {
        
        let nonRequired = makeAnywayPaymentParameter(value: nil, isRequired: false)
        
        XCTAssertTrue(isValid(nonRequired))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOfNonRequiredParameter() {
        
        let nonRequired = makeAnywayPaymentParameter(isRequired: false)
        
        XCTAssertTrue(isValid(nonRequired))
    }
    
    func test_isValid_shouldDeliverFalseOnEmptyValueOfRequiredParameter() {
        
        let required = makeAnywayPaymentParameter(value: nil, isRequired: true)
        
        XCTAssertFalse(isValid(required))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOfRequiredParameter() {
        
        let required = makeAnywayPaymentParameter(isRequired: true)
        
        XCTAssertTrue(isValid(required))
    }
    
    // MARK: - min length
    
    func test_isValid_shouldDeliverTrueOnNilValueOnEmptyMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: nil)
        
        XCTAssertTrue(isValid(none))
    }
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOnEmptyMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: nil)
        
        XCTAssertTrue(isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOnEmptyMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: nil)
        
        XCTAssertTrue(isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverTrueOnNilValueOnZeroMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: 0)
        
        XCTAssertTrue(isValid(none))
    }
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOnZeroMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: 0)
        
        XCTAssertTrue(isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOnZeroMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: 0)
        
        XCTAssertTrue(isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverFalseOnNilValueOnMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: 1)
        
        XCTAssertFalse(isValid(none))
    }
    
    func test_isValid_shouldDeliverFalseOnEmptyValueOnMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: 1)
        
        XCTAssertFalse(isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnSameLengthValueOnMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "a", minLength: 1)
        
        XCTAssertTrue(isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverTrueOnLongerValueOnMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: 1)
        
        XCTAssertTrue(isValid(nonEmpty))
    }
    // MARK: - min length
    
    func test_isValid_shouldDeliverTrueOnNilValueOnEmptyMaxLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, maxLength: nil)
        
        XCTAssertTrue(isValid(none))
    }
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOnEmptyMaxLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", maxLength: nil)
        
        XCTAssertTrue(isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOnEmptyMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", maxLength: nil)
        
        XCTAssertTrue(isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverTrueOnNilValueOnZeroMaxLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, maxLength: 0)
        
        XCTAssertTrue(isValid(none))
    }
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOnZeroMaxLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", maxLength: 0)
        
        XCTAssertTrue(isValid(empty))
    }
    
    func test_isValid_shouldDeliverFalseOnNonEmptyValueOnZeroMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", maxLength: 0)
        
        XCTAssertFalse(isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverTrueOnNilValueOnMaxLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, maxLength: 1)
        
        XCTAssertTrue(isValid(none))
    }
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOnMaxLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", maxLength: 1)
        
        XCTAssertTrue(isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnSameLengthValueOnMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "a", maxLength: 1)
        
        XCTAssertTrue(isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverFalseOnLongerValueOnMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", maxLength: 1)
        
        XCTAssertFalse(isValid(nonEmpty))
    }
    
    // MARK: - regExp
    
    func test_isValid_shouldDeliverTrueForNilValueOnEmptyRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: nil, regExp: "")
        
        XCTAssertTrue(isValid(parameter))
    }
    
    func test_isValid_shouldDeliverTrueForEmptyValueOnEmptyRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "", regExp: "")
        
        XCTAssertTrue(isValid(parameter))
    }
    
    func test_isValid_shouldDeliverTrueForNonEmptyValueOnEmptyRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "abc", regExp: "")
        
        XCTAssertTrue(isValid(parameter))
    }
    
    func test_isValid_shouldDeliverTrueForMatchingRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "abc123", regExp: "^[a-zA-Z0-9]+$")
        
        XCTAssertTrue(isValid(parameter))
    }
    
    func test_isValid_shouldDeliverFalseForNonMatchingRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "abc-123", regExp: "^[a-zA-Z0-9]+$")
        
        XCTAssertFalse(isValid(parameter))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentParameterValidator
    private typealias Parameter = AnywayPayment.Element.Parameter
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func isValid(
        _ parameter: Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Bool {
        
        let sut = makeSUT(file: file, line: line)
        
        return sut.isValid(parameter)
    }
}
