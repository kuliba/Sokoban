//
//  AnywayPaymentValidatorTests.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentDomain

final class AnywayPaymentValidator {
    
    private let isValidParameter: IsValidParameter
    
    init(
        isValidParameter: @escaping IsValidParameter
    ) {
        self.isValidParameter = isValidParameter
    }
}

extension AnywayPaymentValidator {
    
    func isValid(_ payment: Payment) -> Bool {
        
        guard !payment.parameters.isEmpty else { return true }
        
        return payment.parameters.allSatisfy(isValidParameter)
    }
}

extension AnywayPaymentValidator {
    
    typealias IsValidParameter = (Parameter) -> Bool
    
    typealias Payment = AnywayPayment
    typealias Parameter = AnywayPayment.Element.Parameter
}

private extension AnywayPayment {
    
    var parameters: [Element.Parameter] { elements.compactMap(\.parameter) }
}

private extension AnywayPayment.Element {
    
    var parameter: Parameter? {
        
        guard case let .parameter(parameter) = self else { return nil }
        
        return parameter
    }
}

import AnywayPaymentCore
import XCTest

final class AnywayPaymentValidatorTests: XCTestCase {
    
    func test_validate_shouldDeliverTrueOnEmptyParameters() {
        
        let payment = makeAnywayPayment()
        let sut = makeSUT(isValidParameter: { _ in false })
        
        XCTAssertTrue(sut.isValid(payment))
        XCTAssertTrue(parameters(of: payment).isEmpty)
    }
    
    func test_validate_shouldDeliverFalseOnOneInvalidParameter() {
        
        let invalidParameter = makeAnywayPaymentParameter(id: "invalid")
        let payment = makeAnywayPayment(parameters: [invalidParameter])
        let isValidParameter: (Parameter) -> Bool = { $0.field.id != "invalid" }
        let sut = makeSUT(isValidParameter: isValidParameter)
        
        XCTAssertFalse(sut.isValid(payment))
        XCTAssertFalse(isValidParameter(invalidParameter))
    }
    
    func test_validate_shouldDeliverFalseOnAllInvalidParameters() {
        
        let invalidOne = makeAnywayPaymentParameter(id: "one")
        let invalidTwo = makeAnywayPaymentParameter(id: "two")
        let payment = makeAnywayPayment(parameters: [invalidOne, invalidTwo])
        let isValidParameter: (Parameter) -> Bool = {
            $0.field.id != "one" && $0.field.id != "two"
        }
        let sut = makeSUT(isValidParameter: isValidParameter)
        
        XCTAssertFalse(sut.isValid(payment))
        XCTAssertFalse(isValidParameter(invalidOne))
        XCTAssertFalse(isValidParameter(invalidTwo))
    }
    
    func test_validate_shouldDeliverTrueOnAllValidParameters() {
        
        let validOne = makeAnywayPaymentParameter()
        let validTwo = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [validOne, validTwo])
        let isValidParameter: (Parameter) -> Bool = { _ in true }
        let sut = makeSUT(isValidParameter: isValidParameter)
        
        XCTAssertTrue(sut.isValid(payment))
        XCTAssertTrue(isValidParameter(validOne))
        XCTAssertTrue(isValidParameter(validTwo))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentValidator
    private typealias Parameter = AnywayPayment.Element.Parameter
    
    private func makeSUT(
        isValidParameter: @escaping (Parameter) -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(isValidParameter: isValidParameter)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
