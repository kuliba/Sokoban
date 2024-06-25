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
        
        let nonRequired = makeAnywayPaymentParameter(value: nil, isRequired: false)
        
        XCTAssertNil(validate(nonRequired))
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOfNonRequiredParameter() {
        
        let nonRequired = makeAnywayPaymentParameter(isRequired: false)
        
        XCTAssertNil(validate(nonRequired))
    }
    
    func test_isValid_shouldDeliverErrorOnEmptyValueOfRequiredParameter() {
        
        let required = makeAnywayPaymentParameter(value: nil, isRequired: true)
        
        XCTAssertNoDiff(validate(required), .emptyRequired)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOfRequiredParameter() {
        
        let required = makeAnywayPaymentParameter(isRequired: true)
        
        XCTAssertNil(validate(required))
    }
    
    // MARK: - min length
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnEmptyMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: nil)
        
        XCTAssertNil(validate(none))
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnEmptyMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: nil)
        
        XCTAssertNil(validate(empty))
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: nil)
        
        XCTAssertNil(validate(nonEmpty))
    }
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnZeroMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: 0)
        
        XCTAssertNil(validate(none))
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnZeroMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: 0)
        
        XCTAssertNil(validate(empty))
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOnZeroMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: 0)
        
        XCTAssertNil(validate(nonEmpty))
    }
    
    func test_isValid_shouldDeliverErrorOnNilValueOnMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: 1)
        
        XCTAssertNoDiff(validate(none), .tooShort)
    }
    
    func test_isValid_shouldDeliverErrorOnEmptyValueOnMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: 1)
        
        XCTAssertNoDiff(validate(empty), .tooShort)
    }
    
    func test_isValid_shouldNotDeliverErrorOnSameLengthValueOnMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "a", minLength: 1)
        
        XCTAssertNil(validate(nonEmpty))
    }
    
    func test_isValid_shouldNotDeliverErrorOnLongerValueOnMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: 1)
        
        XCTAssertNil(validate(nonEmpty))
    }
    
    // MARK: - min length
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnEmptyMaxLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, maxLength: nil)
        
        XCTAssertNil(validate(none))
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnEmptyMaxLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", maxLength: nil)
        
        XCTAssertNil(validate(empty))
    }
    
    func test_isValid_shouldNotDeliverErrorOnNonEmptyValueOnEmptyMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", maxLength: nil)
        
        XCTAssertNil(validate(nonEmpty))
    }
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnZeroMaxLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, maxLength: 0)
        
        XCTAssertNil(validate(none))
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnZeroMaxLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", maxLength: 0)
        
        XCTAssertNil(validate(empty))
    }
    
    func test_isValid_shouldDeliverErrorOnNonEmptyValueOnZeroMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", maxLength: 0)
        
        XCTAssertNoDiff(validate(nonEmpty), .tooLong)
    }
    
    func test_isValid_shouldNotDeliverErrorOnNilValueOnMaxLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, maxLength: 1)
        
        XCTAssertNil(validate(none))
    }
    
    func test_isValid_shouldNotDeliverErrorOnEmptyValueOnMaxLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", maxLength: 1)
        
        XCTAssertNil(validate(empty))
    }
    
    func test_isValid_shouldNotDeliverErrorOnSameLengthValueOnMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "a", maxLength: 1)
        
        XCTAssertNil(validate(nonEmpty))
    }
    
    func test_isValid_shouldDeliverErrorOnLongerValueOnMaxLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", maxLength: 1)
        
        XCTAssertNoDiff(validate(nonEmpty), .tooLong)
    }
    
    // MARK: - regExp
    
    func test_isValid_shouldNotDeliverErrorForNilValueOnEmptyRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: nil, regExp: "")
        
        XCTAssertNil(validate(parameter))
    }
    
    func test_isValid_shouldNotDeliverErrorForEmptyValueOnEmptyRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "", regExp: "")
        
        XCTAssertNil(validate(parameter))
    }
    
    func test_isValid_shouldNotDeliverErrorForNonEmptyValueOnEmptyRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "abc", regExp: "")
        
        XCTAssertNil(validate(parameter))
    }
    
    func test_isValid_shouldNotDeliverErrorForMatchingRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "abc123", regExp: "^[a-zA-Z0-9]+$")
        
        XCTAssertNil(validate(parameter))
    }
    
    func test_isValid_shouldDeliverErrorForNonMatchingRegex() {
        
        let parameter = makeAnywayPaymentParameter(value: "abc-123", regExp: "^[a-zA-Z0-9]+$")
        
        XCTAssertNoDiff(validate(parameter), .regExViolation)
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
    
    private func validate(
        _ parameter: Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AnywayPaymentParameterValidationError? {
        
        let sut = makeSUT(file: file, line: line)
        
        return sut.validate(parameter)
    }
}
