//
//  AnywayPaymentStagedTests.swift
//  
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentStagedTests: XCTestCase {
    
    func test_staged_shouldDeliverEmptyOnEmptyElements() {
        
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssert(payment.staged().isEmpty)
    }
    
    func test_staged_shouldDeliverEmptyOnEmptyParameters() {
        
        let payment = makeAnywayPayment(
            elements: [.field(makeAnywayPaymentField())]
        )
        
        XCTAssert(payment.staged().isEmpty)
    }
    
    func test_staged_shouldDeliverParameterIDs() {
        
        let (parameter1, parameter2) = makeTwoParameters()
        let payment = makeAnywayPayment(elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        
        XCTAssertNoDiff(
            payment.staged(),
            [parameter1.field.id, parameter2.field.id]
        )
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = AnywayPayment.Element.Parameter
    
    private func makeTwoParameters(
    ) -> (parameter1: Parameter, parameter2: Parameter) {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        
        return (parameter1, parameter2)
    }
}
