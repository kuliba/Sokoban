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
    
    func test_uiComponent_shouldDeliverSelectForSelectAndPair() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: "ABC")
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: .pairs([.init(key: "a", value: "1"),]),
            type: .select,
            viewType: .input
        )
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(field: field, uiAttributes: uiAttributes)
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.init(
            id: "123",
            type: .select([.init(key: "a", value: "1"),]),
            value: "ABC"
        )))
    }
    
    func test_uiComponent_shouldDeliverSelectForSelectAndPairs() {
        
        let field = makeAnywayPaymentElementParameterField(id: "123", value: "ABC")
        let uiAttributes = makeAnywayPaymentElementParameterUIAttributes(
            dataType: .pairs([
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
            type: .select([
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
}
