//
//  AnywayPaymentOutlineTests.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentOutlineTests: XCTestCase {
    
    func test_updating_shouldNotChangeAccountCoreOnEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .account)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.updating(with: payment).core, core)
    }
    
    func test_updating_shouldNotChangeCardCoreOnEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .card)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.updating(with: payment).core, core)
    }
    
    func test_updating_shouldNotChangeCoreOnNonEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .account)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(parameters: [makeAnywayPaymentParameter()])
        
        XCTAssertNoDiff(outline.updating(with: payment).core, core)
    }
    
    func test_updating_shouldDeliverEmptyFieldsOnEmptyElementsPayment() {
        
        let core = makeOutlinePaymentCore(productType: .card)
        let outline = makeAnywayPaymentOutline(core: core)
        let payment = makeAnywayPayment(parameters: [makeAnywayPaymentParameter()])

        XCTAssertNoDiff(outline.updating(with: payment).core, core)
    }
    
    func test_updating_shouldNotChangeOnEmptyElementsPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.updating(with: payment), outline)
    }
    
    func test_updating_shouldNotChangeOnEmptyParameters() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let payment = makeAnywayPayment(
            elements: [.field(makeAnywayPaymentField())]
        )
        
        XCTAssertNoDiff(outline.updating(with: payment), outline)
    }
    
    func test_updating_shouldAppendMissingInputFields() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let input1 = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .input)
        let input2 = makeAnywayPaymentParameter(id: "y", value: "Y", viewType: .input)
        let payment = makeAnywayPayment(elements: [.parameter(input1), .parameter(input2), .field(makeAnywayPaymentField())]
        )
        
        let fields = outline.updating(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
            "x": "X",
            "y": "Y",
        ])
    }
    
    func test_updating_shouldNotAppendMissingConstantFields() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let constant = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .constant)
        let payment = makeAnywayPayment(elements: [.parameter(constant), .field(makeAnywayPaymentField())]
        )
        
        let fields = outline.updating(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
        ])
    }
    
    func test_updating_shouldNotAppendMissingOutputFields() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let output = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .output)
        let payment = makeAnywayPayment(elements: [.parameter(output), .field(makeAnywayPaymentField())]
        )
        
        let fields = outline.updating(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
        ])
    }
    
    func test_updating_shouldAppendMissingInputFieldsAndSkipConstantAndOutput() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let constant = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .constant)
        let input = makeAnywayPaymentParameter(id: "y", value: "Y", viewType: .input)
        let output = makeAnywayPaymentParameter(id: "z", value: "z", viewType: .output)
        let payment = makeAnywayPayment(elements: [.parameter(constant), .parameter(input), .parameter(output), .field(makeAnywayPaymentField())]
        )
        
        let fields = outline.updating(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
            "y": "Y",
        ])
    }
    
    func test_updating_shouldUpdateExistingFields() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        let payment = makeAnywayPayment(elements: [.parameter(parameter)])
        
        let fields = outline.updating(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
            "b": "222",
        ])
    }
    
    func test_updating_shouldUpdateExistingAndAppendMissingFields() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let parameter2 = makeAnywayPaymentParameter(id: "x", value: "X")
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        let payment = makeAnywayPayment(elements: [.parameter(parameter), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        
        let fields = outline.updating(with: payment).fields

        XCTAssertNoDiff(fields, [
            "a": "1",
            "b": "222",
            "x": "X"
        ])
    }
}
