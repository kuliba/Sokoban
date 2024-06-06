//
//  AnywayPaymentContextTests.swift
//
//
//  Created by Igor Malyarov on 09.04.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentContextTests: XCTestCase {
    
    // MARK: - restorePayment
    
    func test_restorePayment_shouldNotChangePaymentOnEmptyStaged() {
        
        let context = makeAnywayPaymentContext(elements: [])
        
        let restored = context.restorePayment()
        
        XCTAssertNoDiff(restored, context)
        XCTAssert(context.staged.isEmpty)
    }
    
    func test_restorePayment_shouldChangeParameterValuesToOutlinedForStaged() {
        
        let parameterOne = makeAnywayPaymentParameter(id: "one", value: "ONE")
        let parameterTwo = makeAnywayPaymentParameter(id: "two", value: "TWO")
        let payment = makeAnywayPayment(parameters: [parameterOne, parameterTwo])
        let context = AnywayPaymentContext(
            payment: payment,
            staged: [.init("one")],
            outline: makeAnywayPaymentOutline(["one": "one"]),
            shouldRestart: false
        )
        
        let restored = context.restorePayment()
        
        XCTAssertNoDiff(restored, context.updating(
            payment: payment.updating(elements: [
                .parameter(parameterOne.updating(value: "one")),
                .parameter(parameterTwo)
            ])
        ))
    }
    
    // MARK: - staging
    
    func test_staging_shouldNotChangeEmptyStagedOnEmptyElements() {
        
        let context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.staged.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssert(stagedContext.staged.isEmpty)
    }
    
    func test_staging_shouldNotChangeEmptyStagedOnEmptyParameters() {
        
        let context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())]
        )
        XCTAssert(context.staged.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssert(stagedContext.staged.isEmpty)
    }
    
    func test_staging_shouldAppendParameterIDsToEmptyStaged() {
        
        let (parameter1, parameter2) = makeTwoParameters()
        let context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        XCTAssert(context.staged.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(
            stagedContext.staged,
            [parameter1.field.id, parameter2.field.id]
        )
    }
    
    func test_staging_shouldAppendParameterIDToNonEmptyStaged() {
        
        let (parameter1, parameter2) = makeTwoParameters()
        let context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())],
            staged: [parameter1.field.id]
        )
        XCTAssertFalse(context.staged.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(
            stagedContext.staged,
            [parameter1.field.id, parameter2.field.id]
        )
    }
    
    func test_staging_shouldNotChangeEmptyFieldsOutlineOnEmptyElementsPayment() {
        
        let context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.outline.fields.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssert(stagedContext.outline.fields.isEmpty)
    }
    
    func test_staging_shouldNotChangeOutlineFieldsOnEmptyElementsPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let context = makeAnywayPaymentContext(
            elements: [],
            outline: outline
        )
        XCTAssertFalse(context.outline.fields.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline, outline)
    }
    
    func test_staging_shouldNotChangeOutlineFieldsOnEmptyParametersPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())],
            outline: outline
        )
        XCTAssertFalse(context.outline.fields.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline, outline)
    }
    
    func test_staging_shouldAppendMissingInputToOutline() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let input1 = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .input)
        let input2 = makeAnywayPaymentParameter(id: "y", value: "Y", viewType: .input)
        let context = makeAnywayPaymentContext(
            elements: [.parameter(input1), .parameter(input2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.fields, [
            "a": "1",
            "x": "X",
            "y": "Y",
        ])
    }
    
    func test_staging_shouldAppendMissingInputToOutlineAndSkipConstantAndOutput() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let constant = makeAnywayPaymentParameter(id: "x", value: "X", viewType: .constant)
        let input = makeAnywayPaymentParameter(id: "y", value: "Y", viewType: .input)
        let output = makeAnywayPaymentParameter(id: "z", value: "Z", viewType: .output)
        let context = makeAnywayPaymentContext(
            elements: [.parameter(constant), .parameter(input), .parameter(output), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.fields, [
            "a": "1",
            "y": "Y",
        ])
    }
    
    func test_staging_shouldUpdateOutline() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        let context = makeAnywayPaymentContext(
            elements: [.parameter(parameter)],
            outline: outline
        )
        XCTAssertFalse(context.outline.fields.isEmpty)
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.fields, [
            "a": "1",
            "b": "222",
        ])
    }
    
    // MARK: - update
    
    func test_update_shouldUpdateExistingAndAppendMissing() {
        
        let field = makeAnywayPaymentElementParameterField(id: "b", value: "222")
        let parameter = makeAnywayPaymentParameter(field: field)
        let parameter2 = makeAnywayPaymentParameter(id: "y", value: "Y")
        let outline = makeAnywayPaymentOutline([
            "a": "1",
            "b": "2"
        ])
        let context = makeAnywayPaymentContext(
            elements: [.parameter(parameter), .parameter(parameter2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.fields, [
            "a": "1",
            "b": "222",
            "y": "Y",
        ])
    }
    
    func test_staging_shouldNotChangeEmptyFieldsOutlineCoreOnEmptyElementsPayment() {
        
        let context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.outline.fields.isEmpty)
        let core = context.outline.core
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.core, core)
    }
    
    func test_staging_shouldNotChangeOutlineCoreOnEmptyElementsPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let context = makeAnywayPaymentContext(
            elements: [],
            outline: outline
        )
        let core = context.outline.core
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.core, core)
    }
    
    func test_staging_shouldNotChangeOutlineCoreOnEmptyParametersPayment() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())],
            outline: outline
        )
        let core = context.outline.core
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.core, core)
    }
    
    func test_staging_shouldNotChangeOutlineCoreOnNonEmpty() {
        
        let outline = makeAnywayPaymentOutline(["a": "1"])
        let (parameter1, parameter2) = makeTwoParameters()
        let context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())],
            outline: outline
        )
        let core = context.outline.core
        
        let stagedContext = context.staging()
        
        XCTAssertNoDiff(stagedContext.outline.core, core)
    }
    
    // MARK: - wouldNeedRestart
    
    func test_wouldNeedRestart_shouldDeliverFalseOnEmptyStagedEmptyParameters() {
        
        let context = makeAnywayPaymentContext(elements: [])
        
        XCTAssertFalse(context.wouldNeedRestart)
        XCTAssertTrue(parameters(of: context.payment).isEmpty)
        XCTAssertTrue(context.staged.isEmpty)
    }
    
    func test_wouldNeedRestart_shouldDeliverFalseOnEmptyStagedNonEmptyParameters() {
        
        let context = makeAnywayPaymentContext(elements: [makeAnywayPaymentParameterElement()])
        
        XCTAssertFalse(context.wouldNeedRestart)
        XCTAssertFalse(parameters(of: context.payment).isEmpty)
        XCTAssertTrue(context.staged.isEmpty)
    }
    
    func test_wouldNeedRestart_shouldDeliverFalseOnSameOutlineValuesForStagedAndParameterValues() {
        
        let (id, value) = (anyMessage(), anyMessage())
        let parameter = makeAnywayPaymentParameter(id: id, value: value)
        let context = makeAnywayPaymentContext(
            elements: [.parameter(parameter)],
            staged: [.init(id)],
            outline: makeAnywayPaymentOutline([id: value])
        )
        
        XCTAssertFalse(context.wouldNeedRestart)
    }
    
    func test_wouldNeedRestart_shouldDeliverTrueOnDifferentOutlineValuesForStagedAndParameterValues() {
        
        let (id, value, outlinedValue) = (anyMessage(), anyMessage(), anyMessage())
        let parameter = makeAnywayPaymentParameter(id: id, value: value)
        let context = makeAnywayPaymentContext(
            elements: [.parameter(parameter)],
            staged: .init([.init(id)]),
            outline: makeAnywayPaymentOutline([id: outlinedValue])
        )
        
        XCTAssertTrue(context.wouldNeedRestart)
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = AnywayPayment.Element.Parameter
    
    private func makeAnywayPaymentContext(
        elements: [AnywayPayment.Element],
        staged: AnywayPaymentStaged = [],
        outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
        shouldRestart: Bool = false
    ) -> AnywayPaymentContext {
        
        let payment = makeAnywayPayment(elements: elements)
        return .init(payment: payment, staged: staged, outline: outline, shouldRestart: shouldRestart)
    }
    
    private func makeTwoParameters(
    ) -> (parameter1: Parameter, parameter2: Parameter) {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        
        return (parameter1, parameter2)
    }
}
