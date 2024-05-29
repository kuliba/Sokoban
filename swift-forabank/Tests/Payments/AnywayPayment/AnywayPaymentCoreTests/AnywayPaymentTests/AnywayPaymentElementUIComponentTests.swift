//
//  AnywayPaymentElementUIComponentTests.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentElementUIComponentTests: XCTestCase {
    
    // MARK: - field
    
    func test_uiComponent_shouldDeliverFieldForField() {
        
        let element = makeAnywayPaymentFieldElement(makeAnywayPaymentField(
            id: "123",
            value: "abc",
            title: "CDE"
        ))
        
        XCTAssertNoDiff(element.uiComponent, .field(.init(
            name: "123",
            title: "CDE",
            value: "abc",
            image: nil
        )))
    }
    
    func test_uiComponent_shouldDeliverFieldForFieldWithMD5Hash() {
        
        let element = makeAnywayPaymentFieldElement(makeAnywayPaymentField(
            "123",
            value: "abc",
            title: "CDE",
            image: .md5Hash("md5Hash")
        ))
        
        XCTAssertNoDiff(element.uiComponent, .field(.init(
            name: "123",
            title: "CDE",
            value: "abc",
            image: .md5Hash("md5Hash")
        )))
    }
    
    func test_uiComponent_shouldDeliverFieldForFieldWithSVG() {
        
        let element = makeAnywayPaymentFieldElement(makeAnywayPaymentField(
            "123",
            value: "abc",
            title: "CDE",
            image: .svg("svg")
        ))
        
        XCTAssertNoDiff(element.uiComponent, .field(.init(
            name: "123",
            title: "CDE",
            value: "abc",
            image: .svg("svg")
        )))
    }
    
    func test_uiComponent_shouldDeliverFieldForFieldWithFallback() {
        
        let element = makeAnywayPaymentFieldElement(makeAnywayPaymentField(
            "123",
            value: "abc",
            title: "CDE",
            image: .withFallback(md5Hash: "md5Hash", svg: "svg")
        ))
        
        XCTAssertNoDiff(element.uiComponent, .field(.init(
            name: "123",
            title: "CDE",
            value: "abc",
            image: .withFallback(md5Hash: "md5Hash", svg: "svg")
        )))
    }
    
    // MARK: - parameter
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputNumber_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .number,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputPairs_select() {
        
        let element = makeElement(
            type: .select,
            dataType: makePairsDataType(),
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputString_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .string,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputNumber_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .number,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputPairs_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: makePairsDataType(),
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputString_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .string,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputNumber_input() {
        
        let element = makeElement(
            type: .input,
            dataType: .number,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputPairs_input() {
        
        let element = makeElement(
            type: .input,
            dataType: makePairsDataType(),
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverHiddenParameterTypeForOutputString_input() {
        
        let element = makeElement(
            type: .input,
            dataType: .string,
            viewType: .output
        )
        
        XCTAssertNoDiff(element.parameterType, .hidden)
    }
    
    func test_uiComponent_shouldDeliverNonEditableParameterTypeForConstantNumber_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .number,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableParameterTypeForConstantPairs_select() {
        
        let element = makeElement(
            type: .select,
            dataType: makePairsDataType(),
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableParameterTypeForConstantString_select() {
        
        let element = makeElement(
            type: .select,
            dataType: .string,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableParameterTypeForConstantNumber_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .number,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableParameterTypeForConstantPairs_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: makePairsDataType(),
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableParameterTypeForConstantString_maskList() {
        
        let element = makeElement(
            type: .maskList,
            dataType: .string,
            viewType: .constant
        )
        
        XCTAssertNoDiff(element.parameterType, .nonEditable)
    }
    
    func test_uiComponent_shouldDeliverNonEditableParameterTypeForConstantNumber_input() {
        
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
    
    // MARK: - parameter
    
    func test_uiComponent_shouldDeliverTextInputForInputString() {
        
        let field = makeAnywayPaymentElementParameterField(
            id: "123",
            value: "ABC"
        )
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: .string,
            subTitle: "defg",
            title: "abcde",
            type: .input,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .textInput,
            title: "abcde",
            subtitle: "defg",
            value: "ABC"
        )))
    }
    
    func test_uiComponent_shouldDeliverNilValueSelectForSelectAndPair() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: nil)
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: makePairsDataType(),
            subTitle: "defg",
            title: "abcde",
            type: .select,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .select(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]),
            title: "abcde",
            subtitle: "defg",
            value: nil
        )))
    }
    
    func test_uiComponent_shouldDeliverSelectForSelectAndPair() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: "ABC")
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: makePairsDataType(),
            subTitle: "defg",
            title: "abcde",
            type: .select,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .select(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]),
            title: "abcde",
            subtitle: "defg",
            value: "ABC"
        )))
    }
    
    func test_uiComponent_shouldDeliverSelectForSelectAndPairs() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: "ABC")
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: makePairsDataType(("a", "1"), ("bb", "22")),
            subTitle: "defg",
            title: "abcde",
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
            title: "abcde",
            subtitle: "defg",
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
        
        XCTAssertNoDiff(
            element.uiComponent,
            .widget(.productPicker(.accountID(.init(id))))
        )
    }
    
    func test_uiComponent_shouldDeliverProductPickerWithCardForCoreWidget() {
        
        let id = generateRandom11DigitNumber()
        let element = makeAnywayPaymentWidgetElement(.core(
            makeWidgetPaymentCore(
                productID: id,
                productType: .card
            )
        ))
        
        XCTAssertNoDiff(
            element.uiComponent,
            .widget(.productPicker(.cardID(.init(id))))
        )
    }
    
    // MARK: - Helpers
    
    private typealias DataType = AnywayPayment.Element.Parameter.UIAttributes.DataType
    private typealias Pair = (key: String, value: String)
    
    private func makePairsDataType(
        _ pair: Pair = ("a", "1"),
        _ pairs: Pair...
    ) -> DataType {
        
        let pair = DataType.Pair(key: pair.key, value: pair.value)
        let pairs = pairs.map { DataType.Pair(key: $0.key, value: $0.value) }
        
        return .pairs(pair, [pair] + pairs)
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
