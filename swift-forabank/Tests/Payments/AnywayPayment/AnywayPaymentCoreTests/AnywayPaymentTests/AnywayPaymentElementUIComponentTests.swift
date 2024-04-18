//
//  AnywayPaymentElementUIComponentTests.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentElementUIComponentTests: XCTestCase {
    
    // MARK: - field
    
    func test_uiComponent_shouldDeliverFieldForField() {
        
        let element = makeAnywayPaymentFieldElement(.init(
            id: "123",
            title: "CDE",
            value: "abc"
        ))
        
        XCTAssertNoDiff(element.uiComponent, .field(.init(
            name: "123",
            title: "CDE",
            value: "abc"
        )))
    }
    
    // MARK: - parameter
    
    func test_uiComponent_shouldDeliverHiddenForOutputNumber_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .number,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputPairs_select() {
        
        let element = makeElement(
            type: .select,
            dataType: makePairsDataType(),
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputString_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .string,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputNumber_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .number,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputPairs_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: makePairsDataType(),
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputString_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .string,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputNumber_input() {
        
        let element = makeElement(
            type: .input,
            dataType: .number,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputPairs_input() {
        
        let element = makeElement(
            type: .input,
            dataType: makePairsDataType(),
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenForOutputString_input() {
        
        let element = makeElement(
            type: .input,
            dataType: .string,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantNumber_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .number,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantPairs_select() {
        
        let element = makeElement(
            type: .select,
            dataType: makePairsDataType(),
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantString_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .string,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantNumber_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .number,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantPairs_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: makePairsDataType(),
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantString_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .string,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantNumber_input() {
        
        let element = makeElement(
            type: .input,
            dataType: .number,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantPairs_input() {
        
        let element = makeElement(
            type: .input,
            dataType: makePairsDataType(),
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableForConstantString_input() {
        
        let element = makeElement(
            type: .input,
            dataType: .string,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverTextInputForInputString() {
        
        let field = makeAnywayPaymentElementParameterField(
            id: "123",
            value: "ABC"
        )
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: .string,
            type: .input,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .textInput,
            value: "ABC"
        )))
    }
    
    func test_uiComponent_shouldDeliverNilValueSelectForSelectAndPair() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: nil)
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]),
            type: .select,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .select(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]),
            value: nil
        )))
    }
    
    func test_uiComponent_shouldDeliverSelectForSelectAndPair() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: "ABC")
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]),
            type: .select,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .select(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]),
            value: "ABC"
        )))
    }
    
    func test_uiComponent_shouldDeliverSelectForSelectAndPairs() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: "ABC")
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: .pairs(
                .init(key: "a", value: "1"), [
                    .init(key: "a", value: "1"),
                    .init(key: "bb", value: "22"),
                ]),
            type: .select,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .select(
                .init(key: "a", value: "1"), [
                    .init(key: "a", value: "1"),
                    .init(key: "bb", value: "22"),
                ]),
            value: "ABC"
        )))
    }
    
    // MARK: - widget
    
    func test_uiComponent_shouldDeliverNilOTPForOTPWidgetWithNil() {
        
        let element = makeAnywayPaymentWidgetElement(.otp(nil))
        
        XCTAssertNoDiff(element.uiComponent, .widget(.otp(nil)))
    }
    
    func test_uiComponent_shouldDeliverOTPForOTPWidget() {
        
        let element = makeAnywayPaymentWidgetElement(.otp(123_456))
        
        XCTAssertNoDiff(element.uiComponent, .widget(.otp(123_456)))
    }
    
    func test_uiComponent_shouldDeliverProductPickerWithAccountForCoreWidget() {
        
        let id = generateRandom11DigitNumber()
        let element = makeAnywayPaymentWidgetElement(.core(
            makeWidgetPaymentCore(
                productID: id,
                productType: .account
            )
        ))
        
        XCTAssertNoDiff(element.uiComponent, .widget(.productPicker(.accountID(.init(id)))))
    }
    
    func test_uiComponent_shouldDeliverProductPickerWithCardForCoreWidget() {
        
        let id = generateRandom11DigitNumber()
        let element = makeAnywayPaymentWidgetElement(.core(
            makeWidgetPaymentCore(
                productID: id,
                productType: .card
            )
        ))
        
        XCTAssertNoDiff(element.uiComponent, .widget(.productPicker(.cardID(.init(id)))))
    }
    
    // MARK: - Helpers
    
    private typealias DataType = AnywayPayment.Element.Parameter.UIAttributes.DataType
    
    private func makePairsDataType() -> DataType {
        
        .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1")])
    }
    
    private func makeElement(
        type: AnywayPayment.Element.Parameter.UIAttributes.FieldType,
        dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType,
        viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType
    ) -> AnywayPayment.Element {
        
        makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(
                uiAttributes: makeUIAttributes(
                    type: type,
                    dataType: dataType,
                    viewType: viewType
                )
            )
        )
    }
    
    private func makeUIAttributes(
        type: AnywayPayment.Element.Parameter.UIAttributes.FieldType,
        dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType,
        viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType
    ) -> AnywayPayment.Element.Parameter.UIAttributes {
        
        makeAnywayPaymentElementParameterUIAttributes(
            dataType: dataType,
            type: type,
            viewType: viewType
        )
    }
}

// MARK: - DSL

private extension AnywayPayment.Element {
    
    var parameterType: AnywayPayment.Element.UIComponent.Parameter.ParameterType? {
        
        guard case let .parameter(parameter) = self
        else { return nil }
        
        return parameter.uiComponent.type
    }
}
