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
              isMinLengthValid(parameter)
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
        
        return (parameter.field.value ?? "").count >= minLength
    }
}

import XCTest

final class AnywayPaymentParameterValidatorTests: XCTestCase {
    
    // MARK: - required
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOfNonRequiredParameter() {
        
        let nonRequired = makeAnywayPaymentParameter(value: nil, isRequired: false)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(nonRequired))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOfNonRequiredParameter() {
        
        let nonRequired = makeAnywayPaymentParameter(isRequired: false)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(nonRequired))
    }
    
    func test_isValid_shouldDeliverFalseOnEmptyValueOfRequiredParameter() {
        
        let required = makeAnywayPaymentParameter(value: nil, isRequired: true)
        let sut = makeSUT()
        
        XCTAssertFalse(sut.isValid(required))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOfRequiredParameter() {
        
        let required = makeAnywayPaymentParameter(isRequired: true)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(required))
    }
    
    // MARK: - min length

    func test_isValid_shouldDeliverTrueOnNilValueOnEmptyMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: nil)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(none))
    }
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOnEmptyMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: nil)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOnEmptyMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: nil)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverTrueOnNilValueOnZeroMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: 0)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(none))
    }
    
    func test_isValid_shouldDeliverTrueOnEmptyValueOnZeroMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: 0)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnNonEmptyValueOnZeroMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: 0)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverFalseOnNilValueOnMinLength() {
        
        let none = makeAnywayPaymentParameter(value: .none, minLength: 1)
        let sut = makeSUT()
        
        XCTAssertFalse(sut.isValid(none))
    }
    
    func test_isValid_shouldDeliverFalseOnEmptyValueOnMinLength() {
        
        let empty = makeAnywayPaymentParameter(value: "", minLength: 1)
        let sut = makeSUT()
        
        XCTAssertFalse(sut.isValid(empty))
    }
    
    func test_isValid_shouldDeliverTrueOnSameLengthValueOnMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "a", minLength: 1)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(nonEmpty))
    }
    
    func test_isValid_shouldDeliverTrueOnLongerValueOnMinLength() {
        
        let nonEmpty = makeAnywayPaymentParameter(value: "abc", minLength: 1)
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isValid(nonEmpty))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentParameterValidator
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
