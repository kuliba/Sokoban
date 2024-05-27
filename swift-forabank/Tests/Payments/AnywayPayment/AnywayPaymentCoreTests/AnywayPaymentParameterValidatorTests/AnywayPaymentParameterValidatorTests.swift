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
        
        guard isValidRequired(parameter) else { return false }
        
        return true
    }
}

extension AnywayPaymentParameterValidator {
    
    typealias Parameter = AnywayPayment.Element.Parameter
}

private extension AnywayPaymentParameterValidator {
    
    func isValidRequired(_ parameter: Parameter) -> Bool {
        
        parameter.validation.isRequired
        ? parameter.field.value != nil
        : true
    }
}

import XCTest

final class AnywayPaymentParameterValidatorTests: XCTestCase {
    
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
