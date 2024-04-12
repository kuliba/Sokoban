//
//  AnywayPaymentElementUIComponentTypeTests.swift
//
//
//  Created by Igor Malyarov on 12.04.2024.
//

extension AnywayPayment.Element {
    
    var uiComponentType: AnywayPayment.UIComponentType {
        
        switch self {
        case let .field(field):
            return .field(.init(field))
            
        case let .parameter(parameter):
            return parameter.uiComponentType
            
        case let .widget(widget):
            return widget.uiComponentType
        }
    }
}

extension AnywayPayment.Element.Parameter {
    
    var uiComponentType: AnywayPayment.UIComponentType {
        
        uiAttributes.uiComponentType
    }
}

extension AnywayPayment.Element.Parameter.UIAttributes {
    
    var uiComponentType: AnywayPayment.UIComponentType {
        
        fatalError()
    }
}

extension AnywayPayment.Element.Widget {
    
    var uiComponentType: AnywayPayment.UIComponentType {
        
        switch self {
        case .core:
            return .productPicker
            
        case .otp:
            return .otp
        }
    }
}

extension AnywayPayment {
    
    enum UIComponentType: Equatable {
        
        case field(Field)
        case otp, productPicker
    }
}

extension AnywayPayment.UIComponentType {
    
    struct Field: Equatable {
        
        let name: String
        let title: String
        let value: String
    }
}

private extension AnywayPayment.UIComponentType.Field {
    
    init(_ field: AnywayPayment.Element.Field) {
        
        self.init(
            name: field.id.rawValue,
            title: field.title,
            value: field.value.rawValue
        )
    }
}

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
