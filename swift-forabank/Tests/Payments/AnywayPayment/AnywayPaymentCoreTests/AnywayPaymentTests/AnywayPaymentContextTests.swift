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
    
    func test_stage_shouldNotChangeEmptyFieldsOutlineOnEmptyElementsPayment() {
        
        var context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.outline.fields.isEmpty)
        
        context.stage()
        
        XCTAssert(context.outline.fields.isEmpty)
    }
    
    func test_stage_shouldNotChangeOutlineFieldsOnEmptyElementsPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        var context = makeAnywayPaymentContext(
            elements: [],
            outline: outline
        )
        XCTAssertFalse(context.outline.fields.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(context.outline, outline)
    }
    
    func test_stage_shouldNotChangeOutlineFieldsOnEmptyParametersPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        var context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())],
            outline: outline
        )
        XCTAssertFalse(context.outline.fields.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(context.outline, outline)
    }
    
    func test_stage_shouldAppendMissingInputToOutline() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let input1 = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .input)
        let input2 = makeAnywayPaymentParameter(id: "y", value: "Y", viewType: .input)
        var context = makeAnywayPaymentContext(
            elements: [.parameter(input1), .parameter(input2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        context.stage()
        
        XCTAssertNoDiff(context.outline.fields, [
            "a": "1",
            "x": "X",
            "y": "Y",
        ])
    }
    
    func test_stage_shouldAppendMissingInputToOutlineAndSkipConstantAndOutput() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let constant = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .constant)
        let input = makeAnywayPaymentParameter(id: "y", value: "Y", viewType: .input)
        let output = makeAnywayPaymentParameter(id: "z", value: "Z", viewType: .output)
        var context = makeAnywayPaymentContext(
            elements: [.parameter(constant), .parameter(input), .parameter(output), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        context.stage()
        
        XCTAssertNoDiff(context.outline.fields, [
            "a": "1",
            "y": "Y",
        ])
    }
    
    func test_stage_shouldUpdateOutline() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter)],
            outline: outline
        )
        XCTAssertFalse(context.outline.fields.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(context.outline.fields, [
            "a": "1",
            "b": "222",
        ])
    }
    
    func test_update_shouldUpdateExistingAndAppendMissing() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let parameter2 = makeAnywayPaymentParameter(id: "y", value: "Y")
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter), .parameter(parameter2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        context.stage()
        
        XCTAssertNoDiff(context.outline.fields, [
            "a": "1",
            "b": "222",
            "y": "Y",
        ])
    }
    
    func test_stage_shouldNotChangeEmptyFieldsOutlineCoreOnEmptyElementsPayment() {
        
        var context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.outline.fields.isEmpty)
        let core = context.outline.core
        
        context.stage()
        
        XCTAssertNoDiff(context.outline.core, core)
    }
    
    func test_stage_shouldNotChangeOutlineCoreOnEmptyElementsPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        var context = makeAnywayPaymentContext(
            elements: [],
            outline: outline
        )
        let core = context.outline.core

        context.stage()
        
        XCTAssertNoDiff(context.outline.core, core)
    }
    
    func test_stage_shouldNotChangeOutlineCoreOnEmptyParametersPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        var context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())],
            outline: outline
        )
        let core = context.outline.core

        context.stage()
        
        XCTAssertNoDiff(context.outline.core, core)
    }
    
    func test_stage_shouldNotChangeOutlineCoreOnNonEmpty() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let (parameter1, parameter2) = makeTwoParameters()
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        let core = context.outline.core
        
        context.stage()
        
        XCTAssertNoDiff(context.outline.core, core)
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = AnywayPayment.Element.Parameter
    
    private func makeAnywayPaymentContext(
        elements: [AnywayPayment.Element],
        staged: AnywayPayment.Staged = [],
        outline: AnywayPayment.Outline = makeAnywayPaymentOutline()
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
