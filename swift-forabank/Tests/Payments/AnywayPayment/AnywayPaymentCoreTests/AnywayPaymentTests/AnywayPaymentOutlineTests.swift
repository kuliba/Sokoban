//
//  AnywayPaymentOutlineTests.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentOutlineTests: XCTestCase {
    
    func test_update_shouldNotChangeAccountCoreOnEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .account)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.update(with: payment).core, core)
    }
    
    func test_update_shouldNotChangeCardCoreOnEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .card)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.update(with: payment).core, core)
    }
    
    func test_update_shouldNotChangeCoreOnNonEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .account)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(parameters: [makeAnywayPaymentParameter()])
        
        XCTAssertNoDiff(outline.update(with: payment).core, core)
    }
    
    func test_update_shouldDeliverEmptyFieldsOnEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .card)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(parameters: [makeAnywayPaymentParameter()])

        XCTAssertNoDiff(outline.update(with: payment).core, core)
    }
    
    func test_update_shouldNotChangeOnEmptyElementsPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.update(with: payment), outline)
    }
    
    func test_update_shouldNotChangeOnEmptyParameters() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let payment = makeAnywayPayment(
            elements: [.field(makeAnywayPaymentField())]
        )
        
        XCTAssertNoDiff(outline.update(with: payment), outline)
    }
    
    func test_update_shouldAppendMissingFields() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let parameter1 = makeAnywayPaymentParameter(id: "x", value: "X")
        let parameter2 = makeAnywayPaymentParameter(id: "y", value: "Y")
        let payment = makeAnywayPayment(elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        
        let fields = outline.update(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
            "x": "X",
            "y": "Y",
        ])
    }
    
    func test_update_shouldUpdateExistingFields() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        let payment = makeAnywayPayment(elements: [.parameter(parameter)])
        
        let fields = outline.update(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
            "b": "222",
        ])
    }
    
    func test_update_shouldUpdateExistingAndAppendMissingFields() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let parameter2 = makeAnywayPaymentParameter(id: "x", value: "X")
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        let payment = makeAnywayPayment(elements: [.parameter(parameter), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        
        let fields = outline.update(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
            "b": "222",
            "x": "X"
        ])
    }
}
