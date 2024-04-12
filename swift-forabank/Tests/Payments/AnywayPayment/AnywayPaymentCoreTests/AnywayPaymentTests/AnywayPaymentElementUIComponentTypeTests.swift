//
//  AnywayPaymentElementUIComponentTypeTests.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import XCTest

final class AnywayPaymentElementUIComponentTypeTests: XCTestCase {
    
    // MARK: - field
    
    func test_uiComponentType_shouldDeliverFieldForField() {
        
        let element = makeAnywayPaymentFieldElement(.init(
            id: "123",
            title: "CDE",
            value: "abc"
        ))
        
        XCTAssertNoDiff(element.uiComponentType, .field(.init(
            name: "123",
            title: "CDE",
            value: "abc"
        )))
    }
    
    // MARK: - widget
    
    func test_uiComponentType_shouldDeliverOTPForOTPWidget() {
        
        let element = makeAnywayPaymentWidgetElement(.otp)
        
        XCTAssertNoDiff(element.uiComponentType, .otp)
    }
    
    func test_uiComponentType_shouldDeliverProductPickerForCoreWidget() {
        
        let element = makeAnywayPaymentWidgetElement(.core(makeWidgetPaymentCore(productType: .account)))
        
        XCTAssertNoDiff(element.uiComponentType, .productPicker)
    }
}
