//
//  AnywayPaymentContextTests.swift
//
//
//  Created by Igor Malyarov on 09.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentContextTests: XCTestCase {
    
    func test_stage_shouldNotChangeEmptyStagedOnEmptyElements() {
        
        var context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.staged.isEmpty)
        
        context.stage()
        
        XCTAssert(context.staged.isEmpty)
    }
    
    func test_stage_shouldNotChangeEmptyStagedOnEmptyParameters() {
        
        var context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())]
        )
        XCTAssert(context.staged.isEmpty)
        
        context.stage()
        
        XCTAssert(context.staged.isEmpty)
    }
    
    func test_stage_shouldAppendParameterIDsToEmptyStaged() {
        
        let (parameter1, parameter2) = makeTwoParameters()
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        XCTAssert(context.staged.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(
            context.staged,
            [parameter1.field.id, parameter2.field.id]
        )
    }
    
    func test_stage_shouldAppendParameterIDToNonEmptyStaged() {
        
        let (parameter1, parameter2) = makeTwoParameters()
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())],
            staged: [parameter1.field.id]
        )
        XCTAssertFalse(context.staged.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(
            context.staged,
            [parameter1.field.id, parameter2.field.id]
        )
    }
    
    func test_stage_shouldNotChangeEmptyOutlineOnEmptyElementsPayment() {
        
        var context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.outline.isEmpty)
        
        context.stage()
        
        XCTAssert(context.outline.isEmpty)
    }
    
    func test_stage_shouldNotChangeOutlineOnEmptyElementsPayment() {
        
        let outline: AnywayPayment.Outline = ["a": "1"]
        var context = makeAnywayPaymentContext(
            elements: [],
            outline: outline
        )
        XCTAssertFalse(context.outline.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(context.outline, outline)
    }
    
    func test_stage_shouldNotChangeOutlineOnEmptyParametersPayment() {
        
        let outline: AnywayPayment.Outline = ["a": "1"]
        var context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())],
            outline: outline
        )
        XCTAssertFalse(context.outline.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(context.outline, outline)
    }
    
    func test_stage_shouldAppendMissingToOutline() {
        
        let outline: AnywayPayment.Outline = ["a": "1"]
        let (parameter1, parameter2) = makeTwoParameters()
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        context.stage()
        
        XCTAssertNoDiff(context.outline, [
            "a": "1",
            parameter1.field.id: parameter1.field.value,
            parameter2.field.id: parameter2.field.value
        ])
    }
    
    func test_stage_shouldUpdateOutline() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let outline: AnywayPayment.Outline = [
            "a": "1",
            "b": "2"
        ]
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter)],
            outline: outline
        )
        XCTAssertFalse(context.outline.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(context.outline, [
            "a": "1",
            "b": "222",
        ])
    }
    
    func test_update_shouldUpdateExistingAndAppendMissing() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let parameter2 = makeAnywayPaymentParameter()
        let outline: AnywayPayment.Outline = [
            "a": "1",
            "b": "2"
        ]
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter), .parameter(parameter2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        context.stage()
        
        XCTAssertNoDiff(context.outline, [
            "a": "1",
            "b": "222",
            parameter2.field.id: parameter2.field.value
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = AnywayPayment.Element.Parameter
    
    private func makeAnywayPaymentContext(
        elements: [AnywayPayment.Element],
        staged: AnywayPayment.Staged = [],
        outline: AnywayPayment.Outline = [:]
    ) -> AnywayPaymentContext {
        
        let payment = makeAnywayPayment(elements: elements)
        return .init(payment: payment, staged: staged, outline: outline)
    }
    
    private func makeTwoParameters(
    ) -> (parameter1: Parameter, parameter2: Parameter) {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        
        return (parameter1, parameter2)
    }
}
