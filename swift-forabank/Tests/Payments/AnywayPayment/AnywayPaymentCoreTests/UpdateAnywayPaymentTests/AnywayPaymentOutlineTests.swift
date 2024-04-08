//
//  AnywayPaymentOutlineTests.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentOutlineTests: XCTestCase {
    
    func test_update_shouldDeliverEmptyOnEmptyElementsPayment() {
        
        let outline = AnywayPayment.Outline()
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssert(outline.update(with: payment).isEmpty)
    }
    
    func test_update_shouldNotChangeOnEmptyElementsPayment() {
        
        let outline: AnywayPayment.Outline = ["a": "1"]
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.update(with: payment), outline)
    }
    
    func test_update_shouldNotChangeOnEmptyParameters() {
        
        let outline: AnywayPayment.Outline = ["a": "1"]
        let payment = makeAnywayPayment(
            elements: [.field(makeAnywayPaymentField())]
        )
        
        XCTAssertNoDiff(outline.update(with: payment), outline)
    }
    
    func test_update_shouldDeliverParameterIDs() {
        
        let outline: AnywayPayment.Outline = ["a": "1"]
        let (parameter1, parameter2) = makeTwoParameters()
        let payment = makeAnywayPayment(elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        
        XCTAssertNoDiff(outline.update(with: payment), [
            "a": "1",
            parameter1.field.id: parameter1.field.value,
            parameter2.field.id: parameter2.field.value
        ])
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
