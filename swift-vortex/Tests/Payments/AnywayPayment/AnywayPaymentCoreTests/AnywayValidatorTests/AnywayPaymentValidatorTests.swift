//
//  AnywayPaymentValidatorTests.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentValidatorTests: XCTestCase {
    
    func test_validate_shouldDeliverOTPValidationErrorOnNilOTPAndEmptyParameters() {
        
        let payment = makeAnywayPaymentWithOTP(nil)
        let sut = makeSUT(validateParameter: { _ in nil })
        
        XCTAssertNoDiff(sut.validate(payment), .otpValidationError)
        XCTAssertTrue(parameters(of: payment).isEmpty)
    }
    
    func test_validate_shouldDeliverOTPValidationErrorOnInvalidOTPAndEmptyParameters() {
        
        let payment = makeAnywayPaymentWithOTP(123)
        let sut = makeSUT(validateParameter: { _ in nil })
        
        XCTAssertNoDiff(sut.validate(payment), .otpValidationError)
        XCTAssertTrue(parameters(of: payment).isEmpty)
    }
    
    func test_validate_shouldDeliverFooterValidationErrorOnNilAmountFooterAndEmptyParameters() {
        
        let payment = makeAnywayPayment(amount: nil, footer: .amount)
        let sut = makeSUT(validateParameter: { _ in nil })
        
        XCTAssertNoDiff(sut.validate(payment), .footerValidationError)
        XCTAssertTrue(parameters(of: payment).isEmpty)
    }
    
    func test_validate_shouldDeliverFooterValidationErrorOnInvalidAmountFooterAndEmptyParameters() {
        
        let payment = makeAnywayPayment(amount: -1, footer: .amount)
        let sut = makeSUT(validateParameter: { _ in nil })
        
        XCTAssertNoDiff(sut.validate(payment), .footerValidationError)
        XCTAssertTrue(parameters(of: payment).isEmpty)
    }
    
    func test_validate_shouldDeliverFooterValidationErrorOnInvalidAmountFooterAndValidParameters() {
        
        let payment = makeAnywayPayment(
            amount: -1,
            parameters: [makeAnywayPaymentParameter(), makeAnywayPaymentParameter()],
            footer: .amount
        )
        let sut = makeSUT(validateParameter: { _ in nil })
        
        XCTAssertNoDiff(sut.validate(payment), .footerValidationError)
    }
    
    func test_validate_shouldNotDeliverErrorOnValidFooterAndEmptyParameters() {
        
        let payment = makeAnywayPayment(amount: 1)
        let sut = makeSUT(validateParameter: { _ in nil })
        
        XCTAssertNil(sut.validate(payment))
        XCTAssertTrue(parameters(of: payment).isEmpty)
    }
    
    func test_validate_shouldNotDeliverErrorOnValidFooterAndValidParameters() {
        
        let payment = makeAnywayPayment(
            amount: 1,
            parameters: [makeAnywayPaymentParameter(), makeAnywayPaymentParameter()]
        )
        let sut = makeSUT(validateParameter: { _ in nil })
        
        XCTAssertNil(sut.validate(payment))
    }
    
    func test_validate_shouldNotDeliverErrorOnEmptyParameters() {
        
        let payment = makeAnywayPayment()
        let sut = makeSUT(validateParameter: { _ in .emptyRequired })
        
        XCTAssertNil(sut.validate(payment))
        XCTAssertTrue(parameters(of: payment).isEmpty)
    }
    
    func test_validate_shouldDeliverErrorOnOneInvalidParameter() {
        
        let invalidParameter = makeAnywayPaymentParameter(id: "invalid")
        let payment = makeAnywayPayment(parameters: [invalidParameter])
        let validateParameter: ValidateParameter = { $0.field.id == "invalid" ? .emptyRequired : nil }
        let sut = makeSUT(validateParameter: validateParameter)
        
        XCTAssertNoDiff(
            sut.validate(payment),
            .parameterValidationErrors(["invalid": .emptyRequired])
        )
        XCTAssertNoDiff(
            validateParameter(invalidParameter),
            .emptyRequired
        )
    }
    
    func test_validate_shouldDeliverErrorOnAllInvalidParameters() {
        
        let invalidOne = makeAnywayPaymentParameter(id: "one")
        let invalidTwo = makeAnywayPaymentParameter(id: "two")
        let payment = makeAnywayPayment(parameters: [invalidOne, invalidTwo, makeAnywayPaymentParameter()])
        let validateParameter: ValidateParameter = {
            if $0.field.id == "one" { return .emptyRequired }
            if $0.field.id == "two" { return .regExViolation }
            return nil
        }
        let sut = makeSUT(validateParameter: validateParameter)
        
        XCTAssertNoDiff(sut.validate(payment), .parameterValidationErrors([
            "one": .emptyRequired,
            "two": .regExViolation,
        ]))
        XCTAssertNoDiff(validateParameter(invalidOne), .emptyRequired)
        XCTAssertNoDiff(validateParameter(invalidTwo), .regExViolation)
    }
    
    func test_validate_shouldNotDeliverErrorOnAllValidParameters() {
        
        let validOne = makeAnywayPaymentParameter()
        let validTwo = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [validOne, validTwo])
        let validateParameter: ValidateParameter = { _ in nil }
        let sut = makeSUT(validateParameter: validateParameter)
        
        XCTAssertNil(sut.validate(payment))
        XCTAssertNil(validateParameter(validOne))
        XCTAssertNil(validateParameter(validTwo))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentValidator
    private typealias Parameter = AnywayElement.Parameter
    
    private typealias ValidateParameter = (Parameter) -> AnywayPaymentParameterValidationError?
    private func makeSUT(
        validateParameter: @escaping ValidateParameter,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(validateParameter: validateParameter)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
