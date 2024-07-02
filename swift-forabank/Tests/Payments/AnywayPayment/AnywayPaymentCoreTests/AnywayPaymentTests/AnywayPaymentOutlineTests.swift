//
//  AnywayPaymentOutlineTests.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentOutlineTests: XCTestCase {
    
    func test_updating_shouldUpdateAmount() {
        
        let amount = makeAmount()
        let outline = makeAnywayPaymentOutline()
        let payment = makeAnywayPayment(amount: amount, elements: [])
        
        XCTAssertNoDiff(outline.updating(with: payment).amount, amount)
    }
    
    func test_updating_shouldNotChangeAccountCoreOnEmptyElementsPayment() {
        
        let amount = makeAmount()
        let product = makeOutlineProduct(productType: .account)
        let outline = makeAnywayPaymentOutline(amount: amount, product: product)
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.updating(with: payment).product, product)
    }
    
    func test_updating_shouldNotChangeCardCoreOnEmptyElementsPayment() {
        
        let amount = makeAmount()
        let product = makeOutlineProduct(productType: .card)
        let outline = makeAnywayPaymentOutline(amount: amount, product: product)
        let payment = makeAnywayPayment(elements: [])
        
        XCTAssertNoDiff(outline.updating(with: payment).product, product)
    }
    
    func test_updating_shouldNotChangeCoreOnNonEmptyElementsPayment() {
        
        let amount = makeAmount()
        let product = makeOutlineProduct(productType: .account)
        let outline = makeAnywayPaymentOutline(amount: amount, product: product)
        let payment = makeAnywayPayment(parameters: [makeAnywayPaymentParameter()])
        
        XCTAssertNoDiff(outline.updating(with: payment).product, product)
    }
    
    func test_updating_shouldDeliverEmptyFieldsOnEmptyElementsPayment() {
        
        let amount = makeAmount()
        let product = makeOutlineProduct(productType: .card)
        let outline = makeAnywayPaymentOutline(amount: amount, product: product)
        let payment = makeAnywayPayment(parameters: [makeAnywayPaymentParameter()])
        
        XCTAssertNoDiff(outline.updating(with: payment).product, product)
    }
    
    func test_updating_shouldUpdateAmountOnEmptyElementsPayment() {
        
        let amount = makeAmount()
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let payment = makeAnywayPayment(amount: amount, elements: [])
        
        let updated = outline.updating(with: payment)
        
        XCTAssertNoDiff(updated.amount, amount)
        XCTAssertNotEqual(updated.amount, outline.amount)
        XCTAssertNoDiff(updated.product, outline.product)
        XCTAssertNoDiff(updated.fields, outline.fields)
        XCTAssertNoDiff(updated.payload, outline.payload)
    }
    
    func test_updating_shouldUpdateAmonutOnEmptyParameters() {
        
        let amount = makeAmount()
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let payment = makeAnywayPayment(
            amount: amount,
            elements: [.field(makeAnywayPaymentField())]
        )
        
        let updated = outline.updating(with: payment)
        
        XCTAssertNoDiff(updated.amount, amount)
        XCTAssertNotEqual(updated.amount, outline.amount)
        XCTAssertNoDiff(updated.product, outline.product)
        XCTAssertNoDiff(updated.fields, outline.fields)
        XCTAssertNoDiff(updated.payload, outline.payload)
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
