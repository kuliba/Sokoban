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
    
    func test_uiComponentType_shouldDeliverFieldForField() {
        
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
    
    func test_uiComponentType_shouldDeliverTextInputForInputString() {
        
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(
                uiAttributes: makeAnywayPaymentElementParameterUIAttributes(
                    dataType: .string,
                    type: .input,
                    viewType: .input
                )
            )
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.textInput))
    }
    
    func test_uiComponentType_shouldDeliverSelectForSelectAndPair() {
        
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(
                uiAttributes: makeAnywayPaymentElementParameterUIAttributes(
                    dataType: .pairs([
                        .init(key: "a", value: "1")
                    ]),
                    type: .select,
                    viewType: .input
                )
            )
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.select([
            .init(key: "a", value: "1")
        ])))
    }
    
    func test_uiComponentType_shouldDeliverSelectForSelectAndPairs() {
        
        let element = makeAnywayPaymentParameterElement(
            makeAnywayPaymentParameter(
                uiAttributes: makeAnywayPaymentElementParameterUIAttributes(
                    dataType: .pairs([
                        .init(key: "a", value: "1"),
                        .init(key: "bb", value: "22"),
                    ]),
                    type: .select,
                    viewType: .input
                )
            )
        )
        
        XCTAssertNoDiff(element.uiComponent, .parameter(.select([
            .init(key: "a", value: "1"),
            .init(key: "bb", value: "22"),
        ])))
    }
    
    // MARK: - widget
    
    func test_uiComponentType_shouldDeliverNilOTPForOTPWidgetWithNil() {
        
        let element = makeAnywayPaymentWidgetElement(.otp(nil))
        
        XCTAssertNoDiff(element.uiComponent, .widget(.otp(nil)))
    }
    
    func test_uiComponentType_shouldDeliverOTPForOTPWidget() {
        
        let element = makeAnywayPaymentWidgetElement(.otp(123_456))
        
        XCTAssertNoDiff(element.uiComponent, .widget(.otp(123_456)))
    }
    
    func test_uiComponentType_shouldDeliverProductPickerForCoreWidget() {
        
        let element = makeAnywayPaymentWidgetElement(.core(makeWidgetPaymentCore(productType: .account)))
        
        XCTAssertNoDiff(element.uiComponent, .widget(.productPicker))
    }
}
